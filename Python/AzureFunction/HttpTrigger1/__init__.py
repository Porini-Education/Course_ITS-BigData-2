import logging
from datetime import datetime

import azure.functions as func

def computeAge(birthdate_str):
    birthdate = datetime.strptime(birthdate_str, '%Y-%m-%d')
    today = datetime.now()
    age = today - birthdate
    return age.days // 365.25

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    birthdate = req.params.get('birthdate')
    if not birthdate:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            birthdate = req_body.get('birthdate')
    
    if birthdate:
        age = computeAge(birthdate)
    
    if name and birthdate:
        return func.HttpResponse(f"Hello, {name}. You are {age} so you can access the hidden data.")
    elif not name:
        return func.HttpResponse(f"You are {age}, but you have to provide your name.")
    elif not birthdate:
        return func.HttpResponse(f"Hello, {name}, but you have to provide your birthdate.")
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name and a birthdate in the query string or in the request body for a personalized response.",
             status_code=200
        )