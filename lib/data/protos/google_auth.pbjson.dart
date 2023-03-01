///
//  Generated code. Do not modify.
//  source: google_auth.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use migrationPayloadDescriptor instead')
const MigrationPayload$json = const {
  '1': 'MigrationPayload',
  '2': const [
    const {'1': 'otp_parameters', '3': 1, '4': 3, '5': 11, '6': '.googleauth.MigrationPayload.OtpParameters', '10': 'otpParameters'},
    const {'1': 'version', '3': 2, '4': 1, '5': 5, '10': 'version'},
    const {'1': 'batch_size', '3': 3, '4': 1, '5': 5, '10': 'batchSize'},
    const {'1': 'batch_index', '3': 4, '4': 1, '5': 5, '10': 'batchIndex'},
    const {'1': 'batch_id', '3': 5, '4': 1, '5': 5, '10': 'batchId'},
  ],
  '3': const [MigrationPayload_OtpParameters$json],
  '4': const [MigrationPayload_Algorithm$json, MigrationPayload_OtpType$json],
};

@$core.Deprecated('Use migrationPayloadDescriptor instead')
const MigrationPayload_OtpParameters$json = const {
  '1': 'OtpParameters',
  '2': const [
    const {'1': 'secret', '3': 1, '4': 1, '5': 12, '10': 'secret'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'issuer', '3': 3, '4': 1, '5': 9, '10': 'issuer'},
    const {'1': 'algorithm', '3': 4, '4': 1, '5': 14, '6': '.googleauth.MigrationPayload.Algorithm', '10': 'algorithm'},
    const {'1': 'digits', '3': 5, '4': 1, '5': 5, '10': 'digits'},
    const {'1': 'type', '3': 6, '4': 1, '5': 14, '6': '.googleauth.MigrationPayload.OtpType', '10': 'type'},
    const {'1': 'counter', '3': 7, '4': 1, '5': 3, '10': 'counter'},
  ],
};

@$core.Deprecated('Use migrationPayloadDescriptor instead')
const MigrationPayload_Algorithm$json = const {
  '1': 'Algorithm',
  '2': const [
    const {'1': 'ALGO_INVALID', '2': 0},
    const {'1': 'ALGO_SHA1', '2': 1},
  ],
};

@$core.Deprecated('Use migrationPayloadDescriptor instead')
const MigrationPayload_OtpType$json = const {
  '1': 'OtpType',
  '2': const [
    const {'1': 'OTP_INVALID', '2': 0},
    const {'1': 'OTP_HOTP', '2': 1},
    const {'1': 'OTP_TOTP', '2': 2},
  ],
};

/// Descriptor for `MigrationPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List migrationPayloadDescriptor = $convert.base64Decode('ChBNaWdyYXRpb25QYXlsb2FkElEKDm90cF9wYXJhbWV0ZXJzGAEgAygLMiouZ29vZ2xlYXV0aC5NaWdyYXRpb25QYXlsb2FkLk90cFBhcmFtZXRlcnNSDW90cFBhcmFtZXRlcnMSGAoHdmVyc2lvbhgCIAEoBVIHdmVyc2lvbhIdCgpiYXRjaF9zaXplGAMgASgFUgliYXRjaFNpemUSHwoLYmF0Y2hfaW5kZXgYBCABKAVSCmJhdGNoSW5kZXgSGQoIYmF0Y2hfaWQYBSABKAVSB2JhdGNoSWQahQIKDU90cFBhcmFtZXRlcnMSFgoGc2VjcmV0GAEgASgMUgZzZWNyZXQSEgoEbmFtZRgCIAEoCVIEbmFtZRIWCgZpc3N1ZXIYAyABKAlSBmlzc3VlchJECglhbGdvcml0aG0YBCABKA4yJi5nb29nbGVhdXRoLk1pZ3JhdGlvblBheWxvYWQuQWxnb3JpdGhtUglhbGdvcml0aG0SFgoGZGlnaXRzGAUgASgFUgZkaWdpdHMSOAoEdHlwZRgGIAEoDjIkLmdvb2dsZWF1dGguTWlncmF0aW9uUGF5bG9hZC5PdHBUeXBlUgR0eXBlEhgKB2NvdW50ZXIYByABKANSB2NvdW50ZXIiLAoJQWxnb3JpdGhtEhAKDEFMR09fSU5WQUxJRBAAEg0KCUFMR09fU0hBMRABIjYKB090cFR5cGUSDwoLT1RQX0lOVkFMSUQQABIMCghPVFBfSE9UUBABEgwKCE9UUF9UT1RQEAI=');
