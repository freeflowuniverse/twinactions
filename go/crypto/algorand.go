/*
code sourced from
https://github.com/algorand/docs/blob/master/examples/assets/v2/go/assetExample.go
and modified
*/

package utils

import (
	"context"
	//"crypto/ed25519"
	json "encoding/json"
	"fmt"

	"github.com/algorand/go-algorand-sdk/client/v2/algod"
	"github.com/algorand/go-algorand-sdk/crypto"
	"github.com/algorand/go-algorand-sdk/future"
	"github.com/algorand/go-algorand-sdk/mnemonic"
	"github.com/algorand/go-algorand-sdk/transaction"
	"github.com/algorand/go-algorand-sdk/types"
	// packages above need to be gotten from github
)

//import transaction "github.com/algorand/go-algorand-sdk/future"

// README
// There are a few issues in the code which I have marked with '//*********'


// // Generate Account
func generateAccount() {
	account := crypto.GenerateAccount()
	passphrase, err := mnemonic.FromPrivateKey(account.PrivateKey)
	myAddress := account.Address.String()

	if err != nil {
		fmt.Printf("Error creating transaction: %s\n", err)
	} else {
		fmt.Printf("My address: %s\n", myAddress)
		fmt.Printf("My passphrase: %s\n", passphrase)
		fmt.Println("--> Copy down your address and passpharse for future use.")
		fmt.Println("--> Once secured, press ENTER key to continue...")
		fmt.Scanln()
	}

}

//// Create Asset
// 12 inputs
// 1 returned

// Comments:
// Input "" for manager, reserve, freeze, clawback if not desired.
// I have no idea what the metadataHash is supposed to be
// I don't know what to return in the event of exceptions //*********

func createAsset(algodClient *algod.Client, creatorAccount [2]string, assetNote string, total uint32, decimals uint32, manager string, reserve string, freeze string, clawback string, assetName string, url string, metadataHash string) string {

	// Get network-related transaction parameters and assign
	txParams, err := algodClient.SuggestedParams().Do(context.Background())
	if err != nil {
		fmt.Printf("Error getting suggested tx params: %s\n", err)
		return
	}

	// Set remaining parameters for asset creation
	account := creatorAccount[0]
	feePerByte := txParams.Fee
	firstRound := txParams.FirstRoundValid
	lastRound := txParams.LastRoundValid
	note := []byte(assetNote)
	genesisID := txParams.GenesisID
	genesisHash := txParams.GenesisHash
	defaultFrozen := false
	unitName := assetName

	// Construct the transaction
	txn, err := transaction.MakeAssetCreateTxn(account, feePerByte, firstRound, lastRound, note, genesisID, genesisHash, total, decimals, defaultFrozen, manager, reserve, freeze, clawback,
		unitName, assetName, url, metadataHash)

	if err != nil {
		fmt.Printf("Failed to create txn: %s\n", err)
		return
	}

	confirmedTxn := signSendConfirm(creatorAccount, txn)

	assetID := confirmedTxn.AssetIndex
	// print created asset and asset holding info for this asset
	fmt.Printf("Asset ID: %d\n", assetID)
	printAsset(assetID, creatorAccount[0], algodClient)

	return assetID
}

//// Modify Asset
// 8 inputs, 0 returned

// Comments:
// if no reserve, freeze, clawback, enter "" instead

func modifyAsset(algodClient *algod.Client, currentManager [2]string, assetNote string, assetID uint64, newManager, newReserve, newFreeze, newClawback string) {

	// Get network-related transaction parameters and assign
	txParams, err := algodClient.SuggestedParams().Do(context.Background())
	if err != nil {
		fmt.Printf("Error getting suggested tx params: %s\n", err)
		return
	}

	account := currentManager[0]
	feePerByte := txParams.Fee
	firstRound := txParams.FirstRoundValid
	lastRound := txParams.LastRoundValid
	note := []byte(assetNote)
	genesisID := txParams.GenesisID
	genesisHash := txParams.GenesisHash
	index := assetID
	strictEmptyAddressChecking := true

	txn, err := transaction.MakeAssetConfigTxn(account, feePerByte, firstRound, lastRound, note, genesisID, genesisHash,
		index, newManager, newReserve, newFreeze, newClawback, strictEmptyAddressChecking)

	if err != nil {
		fmt.Printf("Failed to create transaction MakeAssetConfigTxn: %s\n", err)
		return
	}

	signSendConfirm(currentManager, txn)

	// print created assetinfo for this asset
	printAsset(assetID, currentManager[0], algodClient)

}

// // Opt-in To Asset
// 4 inputs
// 0 returned
func optinToAsset(algodClient *algod.Client, assetReceiver [2]string, optinNote string, assetID uint64) {

	// Get network-related transaction parameters and assign
	txParams, err := algodClient.SuggestedParams().Do(context.Background())
	if err != nil {
		fmt.Printf("Error getting suggested tx params: %s\n", err)
		return
	}

	// Set remaining parameters for asset creation
	account := assetReceiver[0]
	feePerByte := txParams.Fee
	firstRound := txParams.FirstRoundValid
	lastRound := txParams.LastRoundValid
	note := []byte(optinNote)
	genesisID := txParams.GenesisID
	genesisHash := txParams.GenesisHash
	index := assetID

	txn, err := transaction.MakeAssetAcceptanceTxn(account, feePerByte, firstRound, lastRound, note, genesisID, genesisHash, index)
	if err != nil {
		fmt.Printf("Failed to create transaction MakeAssetAcceptanceTxn: %s\n", err)
		return
	}
	signSendConfirm(assetReceiver, txn)

	// print created assetholding for this asset and the asset receiver, showing 0 balance
	fmt.Printf("Asset Receiver: %s\n", assetReceiver[0])
	printAsset(assetID, assetReceiver[0], algodClient)
}

//// Transfer Asset
// closeRemainderTo //https://developer.algorand.org/docs/get-details/transactions/transactions/#closeassetto:~:text=AssetCloseTo,of%20the%20asset).
// unsure whether this field should be left as "" or given the sender's address //*********

func transferAsset(algodClient *algod.Client, sender [2]string, receiverAddress, closeRemainderTo string, amount uint32, optinNote string, assetID uint64) {

	txParams, err := algodClient.SuggestedParams().Do(context.Background())
	if err != nil {
		fmt.Printf("Error getting suggested tx params: %s\n", err)
		return
	}

	account := sender[0]
	recipient := receiverAddress
	closeAssetsTo := closeRemainderTo
	feePerByte := txParams.Fee
	firstRound := txParams.FirstRoundValid
	lastRound := txParams.LastRoundValid
	note := []byte(optinNote)
	genesisID := txParams.GenesisID
	genesisHash := txParams.GenesisHash
	index := assetID

	txn, err := transaction.MakeAssetTransferTxn(account, recipient, closeAssetsTo, amount, feePerByte, firstRound, lastRound, note,
		genesisID, genesisHash, index)
	if err != nil {
		fmt.Printf("Failed to create transaction MakeAssetTransfer Txn: %s\n", err)
		return
	}
	signSendConfirm(sender, txn)

	fmt.Printf("Asset Sender: %s\n", sender[0])
	fmt.Printf("Asset Recipient: %s\n", receiverAddress)
	printAsset(assetID, receiverAddress, algodClient)

}

//// Destroy Asset
// You can only destroy an asset if all of the asset units are held by the asset creator.
// At this point, the asset manager can issue a destroyAsset transaction.

func destroyAsset(algodClient *algod.Client, assetManager [2]string, destroyNote string, assetID uint64) {

	txParams, err := algodClient.SuggestedParams().Do(context.Background())
	if err != nil {
		fmt.Printf("Error getting suggested tx params: %s\n", err)
		return
	}

	account := assetManager[0]
	feePerByte := txParams.Fee
	firstRound := txParams.FirstRoundValid
	lastRound := txParams.LastRoundValid
	note := []byte(destroyNote)
	genesisID := txParams.GenesisID
	genesisHash := txParams.GenesisHash
	index := assetID

	txn, err := transaction.MakeAssetDestroyTxn(account, feePerByte, firstRound, lastRound, note, genesisID, genesisHash, index)
	if err != nil {
		fmt.Printf("Failed to create transaction MakeAssetDestroyTxn: %s\n", err)
		return
	}

	signSendConfirm(account, txn)

	fmt.Printf("Asset ID: %d\n", assetID)
	printAsset(assetID, assetManager[0], algodClient)
	fmt.Printf("Account creater should issue a clearAsset transaction to clear the asset from the account holdings, \n")

}

//// Clear Asset
// After an asset has been destroyed by the account manager, the asset creator needs to clear the asset from their account

func clearAsset(algodClient *algod.Client, assetCreator [2]string, assetID uint64) {

	txParams, err := algodClient.SuggestedParams().Do(context.Background())
	if err != nil {
		fmt.Printf("Error getting suggested tx params: %s\n", err)
		return
	}

	account := assetCreator[0]
	recipient := assetCreator[0]
	closeAssetsTo := assetCreator[0]
	amount := 0
	feePerByte := txParams.Fee
	firstRound := txParams.FirstRoundValid
	lastRound := txParams.LastRoundValid
	note := []byte("")
	genesisID := txParams.GenesisID
	genesisHash := txParams.GenesisHash
	index := assetID

	txn, err := transaction.MakeAssetTransferTxn(account, recipient, closeAssetsTo, amount, feePerByte, firstRound, lastRound, note,
		genesisID, genesisHash, index)
	if err != nil {
		fmt.Printf("Failed to create transaction MakeAssetTransfer Txn: %s\n", err)
		return
	}
	signSendConfirm(assetCreator, txn)

	fmt.Printf("Asset Clearer: %s\n", assetCreator[0])
	printAsset(assetID, assetCreator[0], algodClient)

}

//// Send Payment
// closeRemainderTo //https://developer.algorand.org/docs/get-details/transactions/transactions/#closeassetto:~:text=AssetCloseTo,of%20the%20asset).
// unsure whether this field should be left as "" or given the sender's address //*********

func makePayment(algodClient *algod.Client, paymentSender [2]string, receiverAddress string, amount int, paymentNote, closeRemainderTo string, ) {
	
	txParams, err := algodClient.SuggestedParams().Do(context.Background())
	if err != nil {
		fmt.Printf("Error getting suggested tx params: %s\n", err)
		return
	}

	from := paymentSender[0]
	to := receiverAddress
	fee := txParams.Fee
	firstRound := txParams.FirstRoundValid
	lastRound := txParams.LastRoundValid
	note := []byte(paymentNote)
	genesisID := txParams.GenesisID
	genesisHash := txParams.GenesisHash


	txn, err := transaction.MakePaymentTxn(from, to, fee, amount, firstRound, lastRound, note, closeRemainderTo, genesisID, genesisHash)
	if err != nil {
		fmt.Printf("Failed to create transaction MakePaymentTxn Txn: %s\n", err)
		return

	signSendConfirm(paymentSender, txn)

	fmt.Printf("Payment Sender: %s\n", paymentSender[0])
	fmt.Printf("Payment Receiver: %s\n", receiverAddress)

}

//// PRINT ASSET

// support function: prettyPrint prints Go structs

// I don't know why this function isn't valid //*********
func prettyPrint(data interface{}) {
	var p []byte
	//    var err := error
	p, err := json.MarshalIndent(data, "", "\t")
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Printf("%s \n", p)
}

// utility to print specific assert of an account
func printAsset(assetID uint64, address string, client *algod.Client) {

	act, err := client.AccountInformation(address).Do(context.Background())
	if err != nil {
		fmt.Printf("failed to get account information: %s\n", err)
		return
	}
	for _, asset := range act.CreatedAssets {
		if assetID == asset.Index {
			prettyPrint(asset)
			break
		}
	}
}

//// Sign, Send, Confirm

func signSendConfirm(account [2]string, txn types.Transaction) types.Transaction {
	txid, stx, err := crypto.SignTransaction(account[1], txn)
	if err != nil {
		fmt.Printf("Failed to sign transaction: %s\n", err)
		return
	}

	// Broadcast the transaction to the network
	sendResponse, err := algodClient.SendRawTransaction(stx).Do(context.Background())
	if err != nil {
		fmt.Printf("Failed to send transaction: %s\n", err)
		return
	}

	confirmedTxn, err := future.WaitForConfirmation(algodClient, txid, 4, context.Background())
	if err != nil {
		fmt.Printf("Error waiting for confirmation on txID: %s\n", txid)
		return
	}
	fmt.Printf("Confirmed Transaction: %s in Round %d\n", txid, confirmedTxn.ConfirmedRound)

	return confirmedTxn
}
