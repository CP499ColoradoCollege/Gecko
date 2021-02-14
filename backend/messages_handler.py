import flask
from flask import request, make_response, jsonify, abort
from backend import app
from backend.database_handler import get_conn_and_cursor
from datetime import datetime

@app.route("/api/conversations/create", methods=["POST"])
def create_conversation():
    
    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    request_dict = request.get_json()
    if request_dict == None:
        return make_response(jsonify(message="Bad request. Please check that Content-Type is application/json"), 400)
    
    necessary_keys = ['revealIdentity', 'messageBody', 'labels']
    for key in necessary_keys:
        if key not in request_dict:
            return make_response(jsonify(message="The required property '" + key + "' was not included in the request"), 400)
    
    conn, cur = get_conn_and_cursor()
    cur.execute("INSERT IGNORE INTO Users (username, isBanned, isCCSGA, isAdmin, displayName) VALUES (?, 0, 0, 0, ?);", (flask.session.get('CAS_USERNAME'), flask.session.get('CAS_ATTRIBUTES')['cas:displayName']))
    cur.callproc("create_conversation", (request_dict["revealIdentity"], flask.session.get('CAS_USERNAME'), 0))
    conversation_id = cur.fetchall()[0][0]
    cur.nextset()

    if conversation_id == -403:
        conn.rollback()
        return make_response(jsonify({"message": "User is either banned or a CCSGA rep, neither of whom is authorized to initiate new conversations."}), 403)

    cur.callproc("create_message", (conversation_id, flask.session.get('CAS_USERNAME'), request_dict['messageBody'], 0))
    message_id = cur.fetchall()[0][0]
    cur.nextset()

    for label_body in request_dict["labels"]:
        cur.callproc("apply_label", (conversation_id, label_body))
    
    conn.commit()
    return make_response(jsonify({"conversationId": conversation_id, "messageId": message_id}), 201)

@app.route("/api/conversations/<conversation_id>/messages/create", methods=["POST"])
def create_message(conversation_id):

    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp
  
    request_dict = request.get_json()
    if request_dict == None:
        return make_response(jsonify(message="Bad request. Please check that Content-Type is application/json"), 400)
    
    necessary_keys = ['messageBody']
    for key in necessary_keys:
        if key not in request_dict:
            return make_response(jsonify(message="The required property '" + key + "' was not included in the request"), 400)
    
    conn, cur = get_conn_and_cursor()
    cur.callproc("create_message", (conversation_id, flask.session.get('CAS_USERNAME'), request_dict['messageBody'], 0))
    message_id = cur.fetchall()[0][0]
    cur.nextset()
    
    if message_id == -403:
        conn.rollback()
        return make_response(jsonify({"message": "User is either banned or not authorized to post to this conversation"}), 403)
    
    if message_id == -404:
        conn.rollback()
        return make_response(jsonify({"message": "Conversation not found"}), 404)

    conn.commit()
    return make_response(jsonify({"messageId": message_id}), 201)


@app.route("/api/conversations/<conversation_id>", methods=["GET"])
def get_conversation(conversation_id):
    
    # prevent non-signed in users from accessing
    if flask.session.get('CAS_USERNAME') == None:
        resp = make_response(jsonify({"message": "User not authenticated"}), 401)
        resp.headers.set('WWW-Authenticate', 'CAS')
        return resp

    conn, cur = get_conn_and_cursor()
    cur.callproc("get_conversation", (conversation_id, flask.session.get('CAS_USERNAME')))
    messages_query_result = cur.fetchall()

    if messages_query_result == [(-403,)]:
        return make_response(jsonify({"message": "User is either banned or not authorized to view this conversation"}), 403)

    if messages_query_result == [(-404,)]:
        return make_response(jsonify({"message": "Conversation not found"}), 404)

    # Handle the messages query
    messages = dict()
    for message_id, sender_username, sender_display_name, message_body, dateandtime, isRead in messages_query_result:
        messages[message_id] = {"sender": {"username": sender_username, "displayName": sender_display_name}, "body": message_body, "dateTime": dateandtime, "isRead": bool(isRead)}
    
    # Handle the status query
    cur.nextset()
    status = cur.fetchone()[0]

    # Handle the labels query
    cur.nextset()
    labels = []
    for row in cur.fetchall():
        labels.append(row[0])
    
    # Handle the isArchived query
    cur.nextset()
    isArchived = bool(cur.fetchone()[0])

    # Handle the isArchived query
    cur.nextset()
    allIdentitiesRevealed = bool(cur.fetchone()[0])
    
    # Handle the isArchived query
    cur.nextset()
    allMessagesRead = bool(cur.fetchone()[0])

    cur.nextset()

    return make_response(jsonify({"messages": messages, "status": status, "labels": labels, "isArchived": isArchived, "studentIdentityRevealed": allIdentitiesRevealed, "isRead": allMessagesRead}), 200)

