import 'dart:convert';

import 'package:kakunin/screen/home/home_model.dart';
import 'package:fast_rsa/fast_rsa.dart';

class Encode {
  static String clear(dynamic ref) {
    // ignore: invalid_use_of_protected_member
    var items = ref.read(verificationItemsProvider.notifier).state.map((e) => e.item.uriString).toList();
    return json.encode(items);
  }

  static rsa(dynamic ref) async {
    final clearStr = clear(ref);
    var result = await RSA.encryptPKCS1v15(clearStr, publicKey);
    return result;
  }

  static decode(String str) async {
    return await RSA.decryptPKCS1v15(str, privateKey);
  }
}

const publicKey = """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsjGz5KF19VVw4nA77gd9
Y705PL4lA1JGeq5J8O2O6Wx+DgwDPm05LJluZy9aRYDdDRfjvz43UGzlD2jl8bEm
ND22pi5LmL0kDnexPN7ce9xwV/y8OgxWa4kndwl5vhir1oFmn2VF9sNqs16moVFR
DGjiCGnWymDhrOGDmQBEa3lKvMfuPveV6/o2yUjwq5HYrUynTphRuti9G5KPRvYK
s79Yn33j9kZJQ9sI96FtpJ+ALhrbr3hARNI0WBb0AlDdXzfYYrm0QpJWgcEAJD/6
UrCmHVsrysmWHhK57xos4JV++7VmiLsJvWMfGAuMRbseDzK8IaZvfIVZ5dbQ7VZK
owIDAQAB
-----END PUBLIC KEY-----
""";

const privateKey = """-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCyMbPkoXX1VXDi
cDvuB31jvTk8viUDUkZ6rknw7Y7pbH4ODAM+bTksmW5nL1pFgN0NF+O/PjdQbOUP
aOXxsSY0PbamLkuYvSQOd7E83tx73HBX/Lw6DFZriSd3CXm+GKvWgWafZUX2w2qz
XqahUVEMaOIIadbKYOGs4YOZAERreUq8x+4+95Xr+jbJSPCrkditTKdOmFG62L0b
ko9G9gqzv1iffeP2RklD2wj3oW2kn4AuGtuveEBE0jRYFvQCUN1fN9hiubRCklaB
wQAkP/pSsKYdWyvKyZYeErnvGizglX77tWaIuwm9Yx8YC4xFux4PMrwhpm98hVnl
1tDtVkqjAgMBAAECggEAPdfkIDAtOSUbFWtwUS8GRIxShhNT0zBFx6Qfg19fHwIJ
SaS/p3XOxvzFBUi44rBTh4zH/QKBvgbdBJkaXORnZvAYKNqeX/ccwWym9YI/MTmT
P+Y2CUto3s9uA/Ek8GWtlbe5Pw6t1nOB35i06f3HzC/GarcY1YoEKLTnsD0Ygde1
GcKRPWAe7w9GMRHchttCm+P8FRhbOj2/QatZQGo7LB9xGKcQPveJbvWtFjNXY3xt
9sTrLOwEIHfyRn8GKMcHtDNIterNHtR5w0fM2eGr5h5cmwSjCwDaHh+Bjj7yNfFH
PUfmRdv3tK0VEViqb1kToRdMN8vrUqjBN+Mslig/IQKBgQDj0qEXR0hx5GgD2kOI
LAMEUkQBJBw32TTJ8+B1MUYd/FideSU6J4ycCbDHefjYzJeOzfBsupYpXBkxRUOL
EZzfTk+jzNrYOJFv16kc3h2mqdH4zkd5ycr/ZDzgY/V/rMHZl9q40TxoRKOwKYCt
UT0vLKlrPdZb5s9LZeROl52WkQKBgQDIO7jXqn3lSnslO3GHx5rg7Q1mKvmdnfaL
2ZbDi8WETxp/Odatiz3O9vs+A65NvyARqiXMAVoO71cG5TR9dfOXHKhbBQ4byBMy
AnaFLDI4vVFQhD5uQ0QzcaMo7ey4w0fAu+QXzMltNNjwx0mJbS0H50OwDT3hj2KF
kqNHPb/v8wKBgQCkupjmNxGn4GphVsF7xa8MwdsQJCcPLsvftqo2ssErT1pXys/j
I9Okw9EB+yy2vgBcLoZIaAXJtCE3Igj7lmmigYJOQwJ+UzC9+Ob7y5MO/j2ntKez
5PgWAEmQSlap0aV9CzMIbapLDk55QxkauOIPqTB7LYRAgTykHPGe7jvxMQKBgQCc
Rig8gf7iDqBP7bXsv/d75udXPuE0h82dVoQZOCQ+4DIQ68ZGCe+CcTajLuJCIZHY
14/KSZ/NGjU013yBEqa74IzxBN//BMced9eillzX9cHZ8mx7SBqZf+5UimT/ysFc
hgg+HwFyLxXFzfPxwvirO26Tn7IVMgA1ub2fY21CywKBgEvfBalJhu9Ec+Y5GHmh
hfRYGrbW+1L97rAi1JcowkMyC3F8Fy3NKxRzsAX2EbAmYfig+oFITBtWiFVtlvXd
QAQNWTGUAJZBLDQ1Pj+W9cKz7E08aR6OkXF853+bndbWzxP10MRX+BxzfY0CBmuA
TrgSieegXohOpVFCmVB2VFcc
-----END PRIVATE KEY-----
""";
