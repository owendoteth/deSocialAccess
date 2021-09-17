from brownie import accounts, deSocialBetaBuddy, chain
import pytest


@pytest.fixture(scope="module")
def nft():
    return deSocialBetaBuddy.deploy(chain.time() + 1, {'from': accounts[0]})

def test_mint(nft):
    # 0 < mint amount < 11
    # value == price * amount
    with pytest.raises(Exception):
        nft.mint(0, {'from': accounts[1], 'value': '0.075 ether'})
        nft.mint(11, {'from': accounts[1], 'value': '0.075 ether'})
        nft.mint(1, {'from': accounts[1], 'value': '0 ether'})


    # valid mints
    for i in range(1, 11):
        assert nft.mint(i, {'from': accounts[1], 'value': 75000000000000000 * i})

def test_register(nft):

    # cant register unowned token
    with pytest.raises(Exception):
        nft.register(1, accounts[1], {'from': accounts[1]})

    # register self

    assert nft.register(1, accounts[1], {'from': accounts[0]})

    # cant register same token twice
    # user can't already be register
    with pytest.raises(Exception):
        nft.register(1, accounts[0], {'from': accounts[0]})
        nft.register(2, accounts[1], {'from': accounts[0]})

    # token is redeemed && user is registered
    assert nft.redeemed(1) == True
    assert nft.betaUser(accounts[1]) == True


def test_collect(nft):
    # non-owner can't collect
    with pytest.raises(Exception):
        nft.collect({'from': accounts[1]}) 

    # owner collects
    assert nft.collect({'from': accounts[0]}) 