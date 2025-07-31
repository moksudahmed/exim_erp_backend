import pytest
import requests
import json

@pytest.fixture()

def shared_variables():
    shared_v ={
        "base_url":"http://127.0.0.1:8000/api/v1/account"
    }

    return shared_v


def test_fixture_1(shared_variables):
    url = shared_variables['base_url']
    payload={
        "account_name": "Accounts Payable 5",
        "account_type": "liability",
        "balance": 0.00
    }
    respose = requests.post(url, data=json.dumps(payload))
    print(respose.text)
   
    assert respose.status_code == 200

