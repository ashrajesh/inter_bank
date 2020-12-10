pragma solidity ^0.7.0;

contract InterBank {
    enum Status {Null, Processing, Complete}
    enum Action {Null, Debit, Credit}

    struct Transaction{
        address payable Bank_A; // bank that initiates transaction
        address payable Bank_B; // secondary bank
        uint client_A; // account routing number for initiating client
        uint client_B; // routing account number for participating client
        uint amount; // $$$
    }

    mapping (bytes32 => Transaction) transactions;

    event push_transaction(address payable bank_a, address payable bank_b, bytes32 transact_number);
    event confirm_transaction(uint from, uint to, uint amount);
    event verification_failed(uint from, uint to, uint amount, bytes32 transact_number);

    function request_transaction(address payable destination_bank, uint client_A, uint client_B, uint amount) public {
        bytes32 transact_number = sha256(abi.encodePacked(msg.sender, destination_bank, client_A, client_B, amount));
        Transaction memory curr_transaction = transactions[transact_number];

        curr_transaction.Bank_A         = msg.sender;
        curr_transaction.Bank_B         = destination_bank;
        curr_transaction.client_A       = client_A;
        curr_transaction.client_B       = client_B;
        curr_transaction.amount         = amount;

        emit push_transaction(curr_transaction.Bank_A, curr_transaction.Bank_B, transact_number);
    }

    function execute_transaction(bytes32 transact_number) payable public {
        Transaction memory curr_transaction = transactions[transact_number];
        if(msg.sender == curr_transaction.Bank_B){
            curr_transaction.Bank_A.transfer(curr_transaction.amount);
            emit confirm_transaction(curr_transaction.client_A, curr_transaction.client_B, curr_transaction.amount);
        }
        else{
            emit verification_failed(curr_transaction.client_A, curr_transaction.client_B, curr_transaction.amount, transact_number);
        }
    }

    function quick_send(address payable destination_bank, uint amount, uint client_A, uint client_B) payable public{
        destination_bank.transfer(amount);
        emit confirm_transaction(client_A, client_B, amount);
    }
}