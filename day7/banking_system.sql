# Sample account data structure
accounts = {
    101: {"owner": "Alice", "balance": 5000, "fraud_flag": False, "transactions": [100, 200, 50], "access_level": "customer"},
    102: {"owner": "Bob", "balance": 3000, "fraud_flag": True, "transactions": [150, 1000, 500], "access_level": "customer"},
    201: {"owner": "Charlie", "balance": 7000, "fraud_flag": False, "transactions": [300, 500, 100], "access_level": "teller"},
}

def view_account_summary(account_id, role="customer"):
    if account_id in accounts:
        account = accounts[account_id]
        if role == "teller":
            print(f"Account Owner: {account['owner']}")
            print("Sensitive data hidden for teller access.")
        else:
            print(f"Account Owner: {account['owner']}")
            print(f"Internal Fraud Flag: {'Yes' if account['fraud_flag'] else 'No'}")
            print(f"Balance: {account['balance']}")
    else:
        print("Account not found.")
def before_transfer(from_ac, amount):
    # Trigger function to prevent overdraft
    if accounts[from_ac]["balance"] < amount:
        print("Error: Insufficient funds for this transfer (overdraft prevention).")
        return False
    return True
def transfer_funds(from_ac, to_ac, amount):
    # Check if accounts exist
    if from_ac not in accounts or to_ac not in accounts:
        print("One or both accounts not found.")
        return
    
    # Trigger: Check if there's enough balance in the source account before transfer
    if not before_transfer(from_ac, amount):
        return
    
    # Perform the transfer
    accounts[from_ac]["balance"] -= amount
    accounts[to_ac]["balance"] += amount
    
    # Log transactions
    accounts[from_ac]["transactions"].append(-amount)
    accounts[to_ac]["transactions"].append(amount)
    
    print(f"Transfer of {amount} from Account {from_ac} to Account {to_ac} successful.")
def get_transaction_count(account_id):
    if account_id in accounts:
        return len(accounts[account_id]["transactions"])
    else:
        print("Account not found.")
        return 0
# Secure view by teller (limited access to details)
view_account_summary(101, role="teller")
# Output: 
# Account Owner: Alice
# Sensitive data hidden for teller access.

# Secure view by customer (full account details)
view_account_summary(101, role="customer")
# Output:
# Account Owner: Alice
# Internal Fraud Flag: No
# Balance: 5000

# Transfer funds (balance check and overdraft prevention)
transfer_funds(101, 102, 2000)  # Will succeed
# Output: 
# Transfer of 2000 from Account 101 to Account 102 successful.

transfer_funds(101, 102, 4000)  # Will fail due to insufficient funds
# Output:
# Error: Insufficient funds for this transfer (overdraft prevention).

# Get transaction count for an account
print(f"Transaction count for Account 101: {get_transaction_count(101)}")
# Output:
# Transaction count for Account 101: 4
