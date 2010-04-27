# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_db:test:prepare_session',
  :secret      => '912d69d00c984fd619cad9bd264b9c1915f2410bf797395b5f164c88ba6939948c7159476121c80aeca27d3c6868eb33824c3e662e889e4e1231d7966360e66e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
