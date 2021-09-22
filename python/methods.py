import hashlib
import jwt


SECRET = "my2w7wjd7yXF64FIADfJxNs1oupTGAuW"


class Token:
    def generate_token(self, input_password, query):
        if query is not None:
            salt = query[0][0]
            password = query[0][1]
            role = query[0][2]
            hash_pass = hashlib.sha512((input_password + salt).encode()).hexdigest()
            if hash_pass == password:
                en_jwt = jwt.encode({"role": role}, SECRET, algorithm="HS256")
                return en_jwt
            else:
                return False
        else:
            return False


class Restricted:
    def access_data(self, authorization):
        try:
            decoded_role = jwt.decode(
                authorization.replace("Bearer", "")[2:-1],
                SECRET,
                algorithms="HS256",
            )
        except Exception:  # pylint: disable=broad-except
            return False
        if "role" in decoded_role:
            return True
        else:
            return False
