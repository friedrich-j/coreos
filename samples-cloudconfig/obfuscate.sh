#!/bin/sh
find . -maxdepth 1 -name "*.yaml" -print0 | xargs -L1 -0 sed -r -i.bak 's#^ +- +ssh-rsa +.*$#  - ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAynHnpiFoudQXQMDJ8G7MxD/dHcJltopYCgyJmbowHJaG0a1RqusCSemFvWXztEPzp5IxUqnDgNMAwrgGey7YnDPnPSwpPzKqc6dIRecDRMtFZDgQkAbKKkjZKabqAd7uQGKKqo1QPQjvPf7JKpjIcmnn00pH8hW/lrU79FyaiisqaAXvjtPnMT+AyCHYIic0gYqyl5+D4pSnyh0jsIOf0BTGikaubcLVSYp1dn6XA8HMVhoYL7vLwGD+4bPxz6A16mBKLw6km0EYAUrZEetYqZ1av67oJ6oj8M/+0POfn6L5Zx6tkRnfwkZ8yn+E0ckdoRLQdPRMiUr27KZOiid1Vw== john.doe@nowhere.com#g' 
rm *.bak
