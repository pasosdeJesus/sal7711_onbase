# encoding: UTF-8

conexion = ActiveRecord::Base.connection();

# De motores y finalmente de este
motor = ['sip', 'sal7711_gen', nil]
motor.each do |m|
    Sip::carga_semillas_sql(conexion, m, :cambios)
    Sip::carga_semillas_sql(conexion, m, :datos)
end

conexion.execute("INSERT INTO usuario 
	(nusuario, email, encrypted_password, password, 
  fechacreacion, created_at, updated_at, rol, confirmed_at) 
	VALUES ('sal7711', 'sal7711', 
	'$2a$10$RzZB8e0HK/RF4jTnTB7kiOEa7Hc/pI.xBGaXqhjTm1YFHVFEPFKEG', 
	'', '2014-08-26', '2014-08-26', '2014-08-26', 1, '2015-05-07');")

