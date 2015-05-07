# Be sure to restart your server when you modify this file.
# encoding: UTF-8

# https://www.owasp.org/index.php/Session_Management_Cheat_Sheet
#
Sal7711::Application.config.session_store :cookie_store, 
	key: '_sal7711_session',
	:expire_after => 2.hours
