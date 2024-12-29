from urllib.parse import parse_qs
from rest_framework.authentication import TokenAuthentication
from rest_framework.exceptions import AuthenticationFailed
from channels.db import database_sync_to_async
import requests

class AnonymousUser:
    """Custom anonymous user class."""

    id = None
    is_authenticated = False
    is_anonymous = True
    is_staff = False
    is_superuser = False

    def __str__(self):
        return "AnonymousUser"

    def __bool__(self):
        return False

class User:
    """Custom user class."""

    def __init__(self, id):
        self.id = id
        self.is_authenticated = True

    def __str__(self):
        return f"User {self.id}"
    

class TokenAuthMiddleware:
    """
    Custom middleware to authenticate user using a token in WebSocket.

    Attributes:
        inner (callable): The inner application callable.
    """

    def __init__(self, inner):
        """
        Initialize the middleware with the inner application.

        Args:
            inner (callable): The inner application callable.
        """
        self.inner = inner

    async def __call__(self, scope, receive, send):
        """
        Handle the WebSocket connection and authenticate the user.

        Args:
            scope (dict): The connection scope.
            receive (callable): The receive callable.
            send (callable): The send callable.

        Returns:
            callable: The inner application callable with the updated scope.
        """
        query_string = parse_qs(scope["query_string"].decode() if scope["query_string"] else "")
        print(f"Query string: {query_string}")
        token_key = query_string.get("token", [None])[0]  # Extract token

        if token_key:
            print(f"Token key: {token_key}")
            try:
                user = await self.get_user_from_api(token_key)
                scope["user"] = user
            except AuthenticationFailed:
                scope["user"] = AnonymousUser()
        else:
            scope["user"] = AnonymousUser()

        try:
            return await self.inner(scope, receive, send)
        except Exception as e:
            # Handle the exception (e.g., log it, send an error response, etc.)
            scope["user"] = AnonymousUser()
            raise e

    @database_sync_to_async
    def get_user_from_api(self, token_key):
        try:
            # Replace this URL with your authentication API endpoint
            auth_url = "http://127.0.0.1:8800/user/verify/"
            headers= {
                      "Content-Type": "application/json",
                      "Authorization": f"Bearer {token_key}",
                    }
            response = requests.get(auth_url, headers=headers)
            response.raise_for_status()  # Raise error for non-200 responses
            
            # Extract user details from the API response (customize as per your API response)
            user_data = response.json()
            user_id = user_data.get("user_id")  # Assuming the API returns `user_id`
            
            return User(user_id)

        except (requests.RequestException, KeyError, User.DoesNotExist, AuthenticationFailed):
            return AnonymousUser()