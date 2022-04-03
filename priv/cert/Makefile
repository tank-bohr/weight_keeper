cacert-key.pem:
	openssl genrsa -des3 -out cacert-key.pem 2048

cacert.pem: cacert-key.pem
	openssl req -x509 -new -nodes -key cacert-key.pem -sha256 -days 1825 -out cacert.pem

key.pem:
	openssl genrsa -out key.pem 2048

csr.pem: key.pem
	openssl req -new -key key.pem -out csr.pem

cert.pem: cacert-key.pem cacert.pem csr.pem weight-keeper.local.ext
	openssl x509 \
		-req \
		-in csr.pem \
		-CA cacert.pem \
		-CAkey cacert-key.pem \
		-CAcreateserial \
		-out cert.pem \
		-days 825 \
		-sha256 \
		-extfile weight-keeper.local.ext

clean:
	rm *.pem
