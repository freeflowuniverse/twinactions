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
	// packages above need to be gotten from github
)

//import transaction "github.com/algorand/go-algorand-sdk/future"

//// PRINT ASSET

// support function: prettyPrint prints Go structs
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
// I don't know what to return in the event of exceptions

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
		fmt.Printf("Failed to make asset: %s\n", err)
		return
	}

	fmt.Printf("Asset created AssetName: %s\n", txn.AssetConfigTxnFields.AssetParams.AssetName)
	// sign the transaction
	txid, stx, err := crypto.SignTransaction(creatorAccount[1], txn)
	if err != nil {
		fmt.Printf("Failed to sign transaction: %s\n", err)
		return
	}
	// Broadcast the transaction to the network
	sendResponse, err := algodClient.SendRawTransaction(stx).Do(context.Background())
	if err != nil {
		fmt.Printf("failed to send transaction: %s\n", err)
		return
	}
	fmt.Printf("Submitted transaction %s\n", sendResponse)
	// Wait for confirmation
	confirmedTxn, err := future.WaitForConfirmation(algodClient, txid, 4, context.Background())
	if err != nil {
		fmt.Printf("Error waiting for confirmation on txID: %s\n", txid)
		return
	}
	fmt.Printf("Confirmed Transaction: %s in Round %d\n", txid, confirmedTxn.ConfirmedRound)
	assetID := confirmedTxn.AssetIndex
	// print created asset and asset holding info for this asset
	fmt.Printf("Asset ID: %d\n", assetID)

	return assetID
}

//// Modify Asset

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
		fmt.Printf("Failed to send transaction MakeAssetAcceptanceTxn: %s\n", err)
		return
	}
	txid, stx, err := crypto.SignTransaction(assetReceiver[1], txn)
	if err != nil {
		fmt.Printf("Failed to sign transaction: %s\n", err)
		return
	}

	// Broadcast the transaction to the network
	sendResponse, err := algodClient.SendRawTransaction(stx).Do(context.Background())
	if err != nil {
		fmt.Printf("failed to send transaction: %s\n", err)
		return
	}

	confirmedTxn, err := future.WaitForConfirmation(algodClient, txid, 4, context.Background())
	if err != nil {
		fmt.Printf("Error waiting for confirmation on txID: %s\n", txid)
		return
	}
	fmt.Printf("Confirmed Transaction: %s in Round %d\n", txid, confirmedTxn.ConfirmedRound)

	// print created assetholding for this asset and the asset receiver, showing 0 balance
	fmt.Printf("Asset ID: %d\n", assetID)
	fmt.Printf("Asset Receiver: %s\n", assetReceiver[0])
	printAsset(assetID, assetReceiver[0], algodClient)
}

//// Transfer Asset
// closeRemainderTo //https://developer.algorand.org/docs/get-details/transactions/transactions/#closeassetto:~:text=AssetCloseTo,of%20the%20asset).
// unsure whether this field should be left as "" or given the sender's address

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
		fmt.Printf("Failed to send transaction MakeAssetTransfer Txn: %s\n", err)
		return
	}
	txid, stx, err := crypto.SignTransaction(sender[1], txn)
	if err != nil {
		fmt.Printf("Failed to sign transaction: %s\n", err)
		return
	}
	// Broadcast the transaction to the network
	sendResponse, err := algodClient.SendRawTransaction(stx).Do(context.Background())
	if err != nil {
		fmt.Printf("failed to send transaction: %s\n", err)
		return
	}
	// Wait for transaction to be confirmed
	confirmedTxn, err := future.WaitForConfirmation(algodClient, txid, 4, context.Background())
	if err != nil {
		fmt.Printf("Error waiting for confirmation on txID: %s\n", txid)
		return
	}
	fmt.Printf("Confirmed Transaction: %s in Round %d\n", txid, confirmedTxn.ConfirmedRound)

	fmt.Printf("Asset ID: %d\n", assetID)
	fmt.Printf("Asset Sender: %s\n", sender[0])
	fmt.Printf("Asset Recipient: %s\n", receiverAddress)
	printAsset(assetID, receiverAddress, algodClient)

}

//// Destroy Asset

//// Send Payment

//// Sign, Send, Confirm

// func signSendConfirm() //**** To be created next
