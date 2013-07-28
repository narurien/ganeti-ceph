ganeti-ceph
===========

RBD userspace support for ganeti
This is based on  Pulkit Singhal's GsoC project
with the addition of being backported to stable-2.7

Features:
New cluster setting "rbd:access"
example: gnt-cluster modify -D rbd:access=userspace
