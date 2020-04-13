import argparse
import json
from typing import List

import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

class Action(object):
    """
    Converts a list of tokens into some action that should be performed on the data
    """
    @classmethod
    def from_tokens(cls, tokens: List[str]):
        return Action()

    def perform(self, on: str) -> str:
        return json.dumps(self.transform(json.loads(data_str)))

    def transform(self, data: dict) -> dict:
        return data

    def after_push(self):
        pass

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("project_id")
    parser.add_argument("collection")
    parser.add_argument("document")
    parser.add_argument("invocation", nargs="*")
    args = parser.parse_args()

    # Parse the invocation
    action = Action.from_tokens(args.invocation)

    # Log in
    credentials = credentials.ApplicationDefault()
    firebase_admin.initialize_app(credentials, {
        "projectId": args.project_id
    })
    db = firestore.client()

    # Transform the data and update if changed
    data_ref = db.collection(args.collection).document(args.document)
    data_in = data_ref.get("json")
    data_out = action.perform(on=data_in)
    if data_out != data_in:
        data_ref.set({ "json": data_out })

    # Perform any remaining work after the data has been pushed
    action.after_push()
