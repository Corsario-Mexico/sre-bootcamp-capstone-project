# pylint: disable=line-too-long
import unittest
from methods import Token, Restricted

JWT_ADMIN = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiYWRtaW4ifQ.BmcZ8aB5j8wLSK8CqdDwkGxZfFwM1X1gfAIN7cXOx9w"
JWT_NOADMIN = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiZWRpdG9yIn0.C01pddxYdEY0qum6u_jlQYx3QWpf5NwXJtMq1yoWhc0"
JWT_BOB = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoidmlld2VyIn0._k6kmfmdOoKWWMT4qk9nFTz-7k-X_0UdS8tByaCaye8"

HSP_ADMIN = "15e24a16abfc4eef5faeb806e903f78b188c30e4984a03be4c243312f198d1229ae8759e98993464cf713e3683e891fb3f04fbda9cc40f20a07a58ff4bb00788"
HSP_NOADMIN = "89155af89e8a34dcbde088c72c3f001ac53486fcdb3946b1ed3fde8744ac397d99bf6f44e005af6f6944a1f7ed6bd0e2dd09b8ea3bcfd3e8862878d1709712e5"
HSP_BOB = "2c9dab627bd73b6c4be5612ff77f18fa69fa7c2a71ecedb45dcec45311bea736e320462c6e8bfb2421ed112cfe54fac3eb9ff464f3904fe7cc915396b3df36f0"


class TestStringMethods(unittest.TestCase):
    def setUp(self):
        self.convert = Token()
        self.validate = Restricted()

    def test_generate_token_admin(self):
        self.assertEqual(
            JWT_ADMIN,
            self.convert.generate_token(
                "secret",
                [
                    [
                        "F^S%QljSfV",
                        HSP_ADMIN,
                        "admin",
                    ]
                ],
            ),
        )

    def test_generate_token_noadmin(self):
        self.assertEqual(
            JWT_NOADMIN,
            self.convert.generate_token(
                "noPow3r",
                [
                    [
                        "KjvFUC#K*i",
                        HSP_NOADMIN,
                        "editor",
                    ]
                ],
            ),
        )

    def test_generate_token_bob(self):
        self.assertEqual(
            JWT_BOB,
            self.convert.generate_token(
                "thisIsNotAPasswordBob",
                [
                    [
                        "F^S%QljSfV",
                        HSP_BOB,
                        "viewer",
                    ]
                ],
            ),
        )

    def test_generate_token_wrong_password(self):
        self.assertFalse(
            self.convert.generate_token(
                "WrongPassword",
                [
                    [
                        "F^S%QljSfV",
                        HSP_BOB,
                        "viewer",
                    ]
                ],
            ),
        )

    def test_generate_token_wrong_salt(self):
        self.assertFalse(
            self.convert.generate_token(
                "thisIsNotAPasswordBob",
                [
                    [
                        "F^S%QljSfB",
                        HSP_BOB,
                        "viewer",
                    ]
                ],
            ),
        )

    def test_generate_token_wrong_hsp(self):
        self.assertFalse(
            self.convert.generate_token(
                "thisIsNotAPasswordBob",
                [
                    [
                        "F^S%QljSfV",
                        HSP_ADMIN,
                        "viewer",
                    ]
                ],
            ),
        )

    def test_access_data_admin(self):
        self.assertTrue(
            self.validate.access_data("Bearer: " + JWT_ADMIN + " "),
        )

    def test_access_data_noadmin(self):
        self.assertTrue(
            self.validate.access_data("Bearer: " + JWT_NOADMIN + " "),
        )

    def test_access_data_bob(self):
        self.assertTrue(
            self.validate.access_data("Bearer: " + JWT_BOB + " "),
        )


if __name__ == "__main__":
    unittest.main()
