import contextlib
import io
import os
import pathlib
import runpy
import unittest
from unittest.mock import Mock, patch

import tweepy


SCRIPT = pathlib.Path(__file__).resolve().parents[1] / "post_to_x.py"
SECRETS = {
    "X_API_KEY": "test-key",
    "X_API_SECRET": "test-secret",
    "X_ACCESS_TOKEN": "test-token",
    "X_ACCESS_TOKEN_SECRET": "test-token-secret",
}


class PostToXTest(unittest.TestCase):
    def run_script(self, error=None, dry_run="0"):
        client = Mock()
        client.create_tweet.side_effect = error
        client.create_tweet.return_value.data = {"id": "123"}
        output = io.StringIO()
        with patch.dict(os.environ, {**SECRETS, "DRY_RUN": dry_run}, clear=True), \
                patch("tweepy.Client", return_value=client), \
                contextlib.redirect_stdout(output):
            try:
                runpy.run_path(str(SCRIPT), run_name="__main__")
            except SystemExit as exc:
                return exc.code, output.getvalue(), client
        return None, output.getvalue(), client

    def test_payment_required_reports_billing_and_fails_without_response_details(self):
        response = Mock(status_code=402, reason="Payment Required")
        error = tweepy.HTTPException(response, response_json={"detail": "private response"})
        code, output, client = self.run_script(error)
        self.assertIn("HTTP 402", code)
        self.assertIn("billing", code)
        self.assertNotIn("private response", code)
        client.create_tweet.assert_called_once()

    def test_other_errors_remain_failures(self):
        response = Mock(status_code=500, reason="Server Error")
        error = tweepy.HTTPException(response, response_json={})
        code, _, _ = self.run_script(error)
        self.assertEqual(code, "X API request failed: HTTPException (HTTP 500)")

    def test_success_and_dry_run(self):
        code, output, client = self.run_script()
        self.assertIsNone(code)
        self.assertIn("Posted 123", output)
        client.create_tweet.assert_called_once()

        code, output, client = self.run_script(dry_run="1")
        self.assertEqual(code, 0)
        self.assertIn("[dry run]", output)
        client.create_tweet.assert_not_called()

    def test_duplicate_remains_a_successful_skip(self):
        response = Mock(status_code=403, reason="Forbidden")
        error = tweepy.Forbidden(response, response_json={"detail": "duplicate"})
        code, output, _ = self.run_script(error)
        self.assertEqual(code, 0)
        self.assertIn("already published", output)


if __name__ == "__main__":
    unittest.main()
