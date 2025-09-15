import socket

HOST = "127.0.0.1"
PORT = 7000
BUFFER_SIZE = 4096

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((HOST, PORT))
s.listen(1)
print(f"Listening on {HOST}:{PORT}")

while True:
    conn, addr = s.accept()
    if conn:
        data = b""
        while True:
            chunk = conn.recv(BUFFER_SIZE)
            if not chunk:
                break
            data += chunk
        print("\n----- RAW REQUEST -----")
        print(data.decode(errors="ignore"))
        print("----- END REQUEST -----\n")
