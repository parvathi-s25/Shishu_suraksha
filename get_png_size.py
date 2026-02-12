import struct

with open('assets/images/logo.png', 'rb') as f:
    data = f.read(24)
    w, h = struct.unpack('>II', data[16:24])
    print(f"{w}x{h}")
