from brownie import accounts, deSocialBetaBuddy, Contract

def main():

    # 09/17/21 7:00 pm EST
    timestamp = 1631923200
    dev = accounts.load('beta')
    deSocialBetaBuddy.deploy(timestamp, {'from': dev}, publish_source = True)

