#!/usr/bin/env python3
import secretstorage
connection = secretstorage.dbus_init()

# This should be login keyring, it should have the same password as our user,
# but it will still be locked if we were automatically logged in to our user
# session (since we didn't type in the password in that case).
default = secretstorage.get_default_collection(connection)

# All keyrings (useful if we put all of our credentials in a different keyring)
keyrings = secretstorage.collection.get_all_collections(connection)

# (Try to) unlock them all, starting with default since that can be used to
# store passwords of other keyrings!
for k in ([default] + [kr for kr in keyrings]):
    if k.is_locked():
        # Waits for password to be entered, or dialogue to be dismissed
        k.unlock()
