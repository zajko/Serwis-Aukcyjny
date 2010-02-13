class UserSession < Authlogic::Session::Base
  unloadable
  logout_on_timeout true
end