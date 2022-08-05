/*
code copied from
https://github.com/algorand/docs/blob/master/examples/assets/v2/go/assetExample.go
and modified
*/

package utils

import (
	"context"
	//"crypto/ed25519"
	json "encoding/json"
	"fmt"
	"strings"

	"github.com/algorand/go-algorand-sdk/client/v2/algod"
	"github.com/algorand/go-algorand-sdk/crypto"
	"github.com/algorand/go-algorand-sdk/future"
	"github.com/algorand/go-algorand-sdk/mnemonic"
	"github.com/algorand/go-algorand-sdk/transaction"
	// packages above need to be gotten from github
)

//import transaction "github.com/algorand/go-algorand-sdk/future"

//// PRINT ASSET

// prettyPrint prints Go structs
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

// printCreatedAsset utility to print created assert for account
func printCreatedAsset(assetID uint64, account [2]string, client *algod.Client) {

	act, err := client.AccountInformation(account[0]).Do(context.Background())
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
	/*
		Description:
			Generates a new account on the Algorand Network.

		Output:
			I would want to return a [2]string array but idk how to do so in golang.

	*/
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

// I have no idea what 'assetMetadataHash' is supposed to be
// I dont know how to deal with the mrfc issue. More generally, can you ignore fields like 'note' ie not input them at all.
// How to make function args dependent on a function arg - create new functions
// I need to add the functionality for creating fungible tokens - new function

func createNFT(decimals uint32, algodClient *algod.Client, creatorAccount [2]string, assetName string, assetURL string, manager string, reserve string, freeze string, clawback string) {
	/*
		Description:
			Creates an asset, signs it and sends it to the blockchain to be confirmed.
		Inputs:
			decimals: uint32
				order of magnitude of breakdown of tokens ie decimals = 2 means you can get 0.01 of a token
			algodClient: *algod.Client
				algodClient created with algorand function
			creatorAccount: [2]string
				creator's algorand account as follows: [public_key, private_key]
			assetName: string
				Name of the NFT
			assetURL: string
				URL associated with the NFT
			manager, reserve, freeze, clawback: ints
				The addresses of manager, reserve, freeze and clawback controllers.
				If they are not to be included, then leave as type None.
				*****This feature has not been accomodated.*****

	*/

	// Get network-related transaction parameters and assign
	txParams, err := algodClient.SuggestedParams().Do(context.Background())
	if err != nil {
		fmt.Printf("Error getting suggested tx params: %s\n", err)
		return
	}

	// Construct the transaction
	// Set parameters for asset creation
	creator := creatorAccount[0]
	assetMetadataHash := "thisIsSomeLength32HashCommitment" // I need some input here
	defaultFrozen := false
	note := []byte(nil)
	unitName := strings.ToUpper(assetName)
	totalIssuance := uint32(1)

	txn, err := transaction.MakeAssetCreateTxn(creator,
		note,
		txParams, totalIssuance, decimals,
		defaultFrozen, manager, reserve, freeze, clawback,
		unitName, assetName, assetURL, assetMetadataHash)
	if err != nil {
		fmt.Printf("Failed to make asset: %s\n", err)
		return
	}
	fmt.Printf("Asset created AssetName: %s\n", txn.AssetConfigTxnFields.AssetParams.AssetName)
	// sign the transaction
	txid, stx, err := crypto.SignTransaction(creator[1], txn)
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

}

//// Modify Asset

//// Opt-in To Asset

func optinToAsset(algodClient *algod.Client, assetReceiver [2]string, assetID uint64) {
	/*
		Description:
			Opts-in the asset receiver into the asset given by the asset ID.

		Inputs:
			algodClient: *algod.Client

			assetReceiver: [2]string
				Asset receiver's algorand account as follows: [public_key, private_key]
			assetID: int
				The ID of the asset that the receiver wants to receive.


	*/
	// Use previously set transaction parameters // which previously set parameters?

	// Get network-related transaction parameters and assign
	txParams, err := algodClient.SuggestedParams().Do(context.Background())
	if err != nil {
		fmt.Printf("Error getting suggested tx params: %s\n", err)
		return
	}

	txn, err := transaction.MakeAssetAcceptanceTxn(assetReceiver[0], txParams, assetID)
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
	printCreatedAsset(assetID, assetReceiver, algodClient)
}

//// Transfer Asset

//// Destroy Asset

//// Send Payment
