import os
from flask import Flask, jsonify, request, abort
from convert import CidrMaskConvert, IpValidate
from methods import Token, Restricted
import mysql.connector


app = Flask(__name__)
login = Token()
protected = Restricted()
convert = CidrMaskConvert()
validate = IpValidate()


# DB Connection information from the environment
DB_HOST = os.environ["DB_HOST"]
DB_USER = os.environ["DB_USER"]
DB_PASS = os.environ["DB_PASS"]
DB_NAME = os.environ["DB_NAME"]


# Just a health check
@app.route("/")
def url_root():
    return "OK"


# Just a health check
@app.route("/_health")
def url_health():
    return "OK"


# e.g. http://127.0.0.1:8000/login
@app.route("/login", methods=["POST"])
def url_login():
    username = request.form["username"]
    password = request.form["password"]
    # This database data is here just for you to test, please, remember to define your own DB
    # You can test with username = admin, password = secret
    # This DB has already a best practice: a salt value to store the passwords
    con = mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
    )
    cursor = con.cursor()
    cursor.execute(
        f"SELECT salt, password, role from users where username ='{username}';"
    )
    query = cursor.fetchall()
    query_result = login.generate_token(password, query)
    if query_result is not False:
        query_result_dict = {"data": query_result}
        return jsonify(query_result_dict)
    abort(401)


# e.g. http://127.0.0.1:8000/cidr-to-mask?value=8
@app.route("/cidr-to-mask")
def url_cidr_to_mask():
    var1 = request.headers.get("Authorization")
    if not protected.access_data(var1):
        abort(401)
    val = request.args.get("value")
    result = {
        "function": "cidrToMask",
        "input": val,
        "output": convert.cidr_to_mask(val),
    }
    return jsonify(result)


# # e.g. http://127.0.0.1:8000/mask-to-cidr?value=255.0.0.0
@app.route("/mask-to-cidr")
def url_mask_to_cidr():
    var1 = request.headers.get("Authorization")
    if not protected.access_data(var1):
        abort(401)
    val = request.args.get("value")
    result = {
        "function": "maskToCidr",
        "input": val,
        "output": convert.mask_to_cidr(val),
    }
    return jsonify(result)


# # e.g. http://127.0.0.1:8000/ip-validation?value=255.0.0.0
@app.route("/ip-validation")
def url_ipv4_validation():
    var1 = request.headers.get("Authorization")
    if not protected.access_data(var1):
        abort(401)
    val = request.args.get("value")
    res = {
        "function": "ipv4Validation",
        "input": val,
        "output": validate.ipv4_validation(val),
    }
    return jsonify(res)


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=8000)
