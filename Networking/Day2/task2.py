import socket

def scan_port(host, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(2)  # timeout in seconds
    try:
        s.connect((host, port))
        print(f"Port {port} on {host} is Open")
    except (socket.timeout, socket.error):
        print(f"Port {port} on {host} is Closed")
    finally:
        s.close()

host = input("Enter the host name: ")
port = int(input("Enter the port number: "))
scan_port(host, port)       