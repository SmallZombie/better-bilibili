// This is a generated file - do not edit.
//
// Generated from bilibili.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use dmColorfulTypeDescriptor instead')
const DmColorfulType$json = {
  '1': 'DmColorfulType',
  '2': [
    {'1': 'NoneType', '2': 0},
    {'1': 'VipGradualColor', '2': 60001},
  ],
};

/// Descriptor for `DmColorfulType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List dmColorfulTypeDescriptor = $convert.base64Decode(
    'Cg5EbUNvbG9yZnVsVHlwZRIMCghOb25lVHlwZRAAEhUKD1ZpcEdyYWR1YWxDb2xvchDh1AM=');

@$core.Deprecated('Use dmSegMobileReplyDescriptor instead')
const DmSegMobileReply$json = {
  '1': 'DmSegMobileReply',
  '2': [
    {
      '1': 'elems',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.bilibili.community.service.dm.v1.DanmakuElem',
      '10': 'elems'
    },
    {'1': 'state', '3': 2, '4': 1, '5': 5, '10': 'state'},
    {
      '1': 'ai_flag',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.bilibili.community.service.dm.v1.DanmakuAIFlag',
      '10': 'aiFlag'
    },
    {
      '1': 'colorfulSrc',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.bilibili.community.service.dm.v1.DmColorful',
      '10': 'colorfulSrc'
    },
  ],
};

/// Descriptor for `DmSegMobileReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dmSegMobileReplyDescriptor = $convert.base64Decode(
    'ChBEbVNlZ01vYmlsZVJlcGx5EkMKBWVsZW1zGAEgAygLMi0uYmlsaWJpbGkuY29tbXVuaXR5Ln'
    'NlcnZpY2UuZG0udjEuRGFubWFrdUVsZW1SBWVsZW1zEhQKBXN0YXRlGAIgASgFUgVzdGF0ZRJI'
    'CgdhaV9mbGFnGAMgASgLMi8uYmlsaWJpbGkuY29tbXVuaXR5LnNlcnZpY2UuZG0udjEuRGFubW'
    'FrdUFJRmxhZ1IGYWlGbGFnEk4KC2NvbG9yZnVsU3JjGAUgAygLMiwuYmlsaWJpbGkuY29tbXVu'
    'aXR5LnNlcnZpY2UuZG0udjEuRG1Db2xvcmZ1bFILY29sb3JmdWxTcmM=');

@$core.Deprecated('Use danmakuElemDescriptor instead')
const DanmakuElem$json = {
  '1': 'DanmakuElem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'progress', '3': 2, '4': 1, '5': 5, '10': 'progress'},
    {'1': 'mode', '3': 3, '4': 1, '5': 5, '10': 'mode'},
    {'1': 'fontsize', '3': 4, '4': 1, '5': 5, '10': 'fontsize'},
    {'1': 'color', '3': 5, '4': 1, '5': 13, '10': 'color'},
    {'1': 'midHash', '3': 6, '4': 1, '5': 9, '10': 'midHash'},
    {'1': 'content', '3': 7, '4': 1, '5': 9, '10': 'content'},
    {'1': 'ctime', '3': 8, '4': 1, '5': 3, '10': 'ctime'},
    {'1': 'weight', '3': 9, '4': 1, '5': 5, '10': 'weight'},
    {'1': 'action', '3': 10, '4': 1, '5': 9, '10': 'action'},
    {'1': 'pool', '3': 11, '4': 1, '5': 5, '10': 'pool'},
    {'1': 'idStr', '3': 12, '4': 1, '5': 9, '10': 'idStr'},
    {'1': 'attr', '3': 13, '4': 1, '5': 5, '10': 'attr'},
    {'1': 'animation', '3': 22, '4': 1, '5': 9, '10': 'animation'},
    {
      '1': 'colorful',
      '3': 24,
      '4': 1,
      '5': 14,
      '6': '.bilibili.community.service.dm.v1.DmColorfulType',
      '10': 'colorful'
    },
  ],
};

/// Descriptor for `DanmakuElem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List danmakuElemDescriptor = $convert.base64Decode(
    'CgtEYW5tYWt1RWxlbRIOCgJpZBgBIAEoA1ICaWQSGgoIcHJvZ3Jlc3MYAiABKAVSCHByb2dyZX'
    'NzEhIKBG1vZGUYAyABKAVSBG1vZGUSGgoIZm9udHNpemUYBCABKAVSCGZvbnRzaXplEhQKBWNv'
    'bG9yGAUgASgNUgVjb2xvchIYCgdtaWRIYXNoGAYgASgJUgdtaWRIYXNoEhgKB2NvbnRlbnQYBy'
    'ABKAlSB2NvbnRlbnQSFAoFY3RpbWUYCCABKANSBWN0aW1lEhYKBndlaWdodBgJIAEoBVIGd2Vp'
    'Z2h0EhYKBmFjdGlvbhgKIAEoCVIGYWN0aW9uEhIKBHBvb2wYCyABKAVSBHBvb2wSFAoFaWRTdH'
    'IYDCABKAlSBWlkU3RyEhIKBGF0dHIYDSABKAVSBGF0dHISHAoJYW5pbWF0aW9uGBYgASgJUglh'
    'bmltYXRpb24STAoIY29sb3JmdWwYGCABKA4yMC5iaWxpYmlsaS5jb21tdW5pdHkuc2VydmljZS'
    '5kbS52MS5EbUNvbG9yZnVsVHlwZVIIY29sb3JmdWw=');

@$core.Deprecated('Use danmakuAIFlagDescriptor instead')
const DanmakuAIFlag$json = {
  '1': 'DanmakuAIFlag',
  '2': [
    {
      '1': 'dm_flags',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.bilibili.community.service.dm.v1.DanmakuFlag',
      '10': 'dmFlags'
    },
  ],
};

/// Descriptor for `DanmakuAIFlag`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List danmakuAIFlagDescriptor = $convert.base64Decode(
    'Cg1EYW5tYWt1QUlGbGFnEkgKCGRtX2ZsYWdzGAEgAygLMi0uYmlsaWJpbGkuY29tbXVuaXR5Ln'
    'NlcnZpY2UuZG0udjEuRGFubWFrdUZsYWdSB2RtRmxhZ3M=');

@$core.Deprecated('Use danmakuFlagDescriptor instead')
const DanmakuFlag$json = {
  '1': 'DanmakuFlag',
  '2': [
    {'1': 'dmid', '3': 1, '4': 1, '5': 3, '10': 'dmid'},
    {'1': 'flag', '3': 2, '4': 1, '5': 13, '10': 'flag'},
  ],
};

/// Descriptor for `DanmakuFlag`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List danmakuFlagDescriptor = $convert.base64Decode(
    'CgtEYW5tYWt1RmxhZxISCgRkbWlkGAEgASgDUgRkbWlkEhIKBGZsYWcYAiABKA1SBGZsYWc=');

@$core.Deprecated('Use dmColorfulDescriptor instead')
const DmColorful$json = {
  '1': 'DmColorful',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.bilibili.community.service.dm.v1.DmColorfulType',
      '10': 'type'
    },
    {'1': 'src', '3': 2, '4': 1, '5': 9, '10': 'src'},
  ],
};

/// Descriptor for `DmColorful`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dmColorfulDescriptor = $convert.base64Decode(
    'CgpEbUNvbG9yZnVsEkQKBHR5cGUYASABKA4yMC5iaWxpYmlsaS5jb21tdW5pdHkuc2VydmljZS'
    '5kbS52MS5EbUNvbG9yZnVsVHlwZVIEdHlwZRIQCgNzcmMYAiABKAlSA3NyYw==');

@$core.Deprecated('Use dmSegConfigDescriptor instead')
const DmSegConfig$json = {
  '1': 'DmSegConfig',
  '2': [
    {'1': 'pageSize', '3': 1, '4': 1, '5': 3, '10': 'pageSize'},
    {'1': 'total', '3': 2, '4': 1, '5': 3, '10': 'total'},
  ],
};

/// Descriptor for `DmSegConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dmSegConfigDescriptor = $convert.base64Decode(
    'CgtEbVNlZ0NvbmZpZxIaCghwYWdlU2l6ZRgBIAEoA1IIcGFnZVNpemUSFAoFdG90YWwYAiABKA'
    'NSBXRvdGFs');

@$core.Deprecated('Use danmakuFlagConfigDescriptor instead')
const DanmakuFlagConfig$json = {
  '1': 'DanmakuFlagConfig',
  '2': [
    {'1': 'recFlag', '3': 1, '4': 1, '5': 5, '10': 'recFlag'},
    {'1': 'recText', '3': 2, '4': 1, '5': 9, '10': 'recText'},
    {'1': 'recSwitch', '3': 3, '4': 1, '5': 5, '10': 'recSwitch'},
  ],
};

/// Descriptor for `DanmakuFlagConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List danmakuFlagConfigDescriptor = $convert.base64Decode(
    'ChFEYW5tYWt1RmxhZ0NvbmZpZxIYCgdyZWNGbGFnGAEgASgFUgdyZWNGbGFnEhgKB3JlY1RleH'
    'QYAiABKAlSB3JlY1RleHQSHAoJcmVjU3dpdGNoGAMgASgFUglyZWNTd2l0Y2g=');

@$core.Deprecated('Use commandDmDescriptor instead')
const CommandDm$json = {
  '1': 'CommandDm',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'oid', '3': 2, '4': 1, '5': 3, '10': 'oid'},
    {'1': 'mid', '3': 3, '4': 1, '5': 3, '10': 'mid'},
    {'1': 'command', '3': 4, '4': 1, '5': 9, '10': 'command'},
    {'1': 'content', '3': 5, '4': 1, '5': 9, '10': 'content'},
    {'1': 'progress', '3': 6, '4': 1, '5': 5, '10': 'progress'},
    {'1': 'ctime', '3': 7, '4': 1, '5': 9, '10': 'ctime'},
    {'1': 'mtime', '3': 8, '4': 1, '5': 9, '10': 'mtime'},
    {'1': 'extra', '3': 9, '4': 1, '5': 9, '10': 'extra'},
    {'1': 'idStr', '3': 10, '4': 1, '5': 9, '10': 'idStr'},
  ],
};

/// Descriptor for `CommandDm`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandDmDescriptor = $convert.base64Decode(
    'CglDb21tYW5kRG0SDgoCaWQYASABKANSAmlkEhAKA29pZBgCIAEoA1IDb2lkEhAKA21pZBgDIA'
    'EoA1IDbWlkEhgKB2NvbW1hbmQYBCABKAlSB2NvbW1hbmQSGAoHY29udGVudBgFIAEoCVIHY29u'
    'dGVudBIaCghwcm9ncmVzcxgGIAEoBVIIcHJvZ3Jlc3MSFAoFY3RpbWUYByABKAlSBWN0aW1lEh'
    'QKBW10aW1lGAggASgJUgVtdGltZRIUCgVleHRyYRgJIAEoCVIFZXh0cmESFAoFaWRTdHIYCiAB'
    'KAlSBWlkU3Ry');

@$core.Deprecated('Use danmuWebPlayerConfigDescriptor instead')
const DanmuWebPlayerConfig$json = {
  '1': 'DanmuWebPlayerConfig',
  '2': [
    {'1': 'dmSwitch', '3': 1, '4': 1, '5': 8, '10': 'dmSwitch'},
    {'1': 'aiSwitch', '3': 2, '4': 1, '5': 8, '10': 'aiSwitch'},
    {'1': 'aiLevel', '3': 3, '4': 1, '5': 5, '10': 'aiLevel'},
    {'1': 'blocktop', '3': 4, '4': 1, '5': 8, '10': 'blocktop'},
    {'1': 'blockscroll', '3': 5, '4': 1, '5': 8, '10': 'blockscroll'},
    {'1': 'blockbottom', '3': 6, '4': 1, '5': 8, '10': 'blockbottom'},
    {'1': 'blockcolor', '3': 7, '4': 1, '5': 8, '10': 'blockcolor'},
    {'1': 'blockspecial', '3': 8, '4': 1, '5': 8, '10': 'blockspecial'},
    {'1': 'preventshade', '3': 9, '4': 1, '5': 8, '10': 'preventshade'},
    {'1': 'dmask', '3': 10, '4': 1, '5': 8, '10': 'dmask'},
    {'1': 'opacity', '3': 11, '4': 1, '5': 2, '10': 'opacity'},
    {'1': 'dmarea', '3': 12, '4': 1, '5': 5, '10': 'dmarea'},
    {'1': 'speedplus', '3': 13, '4': 1, '5': 2, '10': 'speedplus'},
    {'1': 'fontsize', '3': 14, '4': 1, '5': 2, '10': 'fontsize'},
    {'1': 'screensync', '3': 15, '4': 1, '5': 8, '10': 'screensync'},
    {'1': 'speedsync', '3': 16, '4': 1, '5': 8, '10': 'speedsync'},
    {'1': 'fontfamily', '3': 17, '4': 1, '5': 9, '10': 'fontfamily'},
    {'1': 'bold', '3': 18, '4': 1, '5': 8, '10': 'bold'},
    {'1': 'fontborder', '3': 19, '4': 1, '5': 5, '10': 'fontborder'},
    {'1': 'drawType', '3': 20, '4': 1, '5': 9, '10': 'drawType'},
  ],
};

/// Descriptor for `DanmuWebPlayerConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List danmuWebPlayerConfigDescriptor = $convert.base64Decode(
    'ChREYW5tdVdlYlBsYXllckNvbmZpZxIaCghkbVN3aXRjaBgBIAEoCFIIZG1Td2l0Y2gSGgoIYW'
    'lTd2l0Y2gYAiABKAhSCGFpU3dpdGNoEhgKB2FpTGV2ZWwYAyABKAVSB2FpTGV2ZWwSGgoIYmxv'
    'Y2t0b3AYBCABKAhSCGJsb2NrdG9wEiAKC2Jsb2Nrc2Nyb2xsGAUgASgIUgtibG9ja3Njcm9sbB'
    'IgCgtibG9ja2JvdHRvbRgGIAEoCFILYmxvY2tib3R0b20SHgoKYmxvY2tjb2xvchgHIAEoCFIK'
    'YmxvY2tjb2xvchIiCgxibG9ja3NwZWNpYWwYCCABKAhSDGJsb2Nrc3BlY2lhbBIiCgxwcmV2ZW'
    '50c2hhZGUYCSABKAhSDHByZXZlbnRzaGFkZRIUCgVkbWFzaxgKIAEoCFIFZG1hc2sSGAoHb3Bh'
    'Y2l0eRgLIAEoAlIHb3BhY2l0eRIWCgZkbWFyZWEYDCABKAVSBmRtYXJlYRIcCglzcGVlZHBsdX'
    'MYDSABKAJSCXNwZWVkcGx1cxIaCghmb250c2l6ZRgOIAEoAlIIZm9udHNpemUSHgoKc2NyZWVu'
    'c3luYxgPIAEoCFIKc2NyZWVuc3luYxIcCglzcGVlZHN5bmMYECABKAhSCXNwZWVkc3luYxIeCg'
    'pmb250ZmFtaWx5GBEgASgJUgpmb250ZmFtaWx5EhIKBGJvbGQYEiABKAhSBGJvbGQSHgoKZm9u'
    'dGJvcmRlchgTIAEoBVIKZm9udGJvcmRlchIaCghkcmF3VHlwZRgUIAEoCVIIZHJhd1R5cGU=');

@$core.Deprecated('Use dmWebViewReplyDescriptor instead')
const DmWebViewReply$json = {
  '1': 'DmWebViewReply',
  '2': [
    {'1': 'state', '3': 1, '4': 1, '5': 5, '10': 'state'},
    {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
    {'1': 'textSide', '3': 3, '4': 1, '5': 9, '10': 'textSide'},
    {
      '1': 'dmSge',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.bilibili.community.service.dm.v1.DmSegConfig',
      '10': 'dmSge'
    },
    {
      '1': 'flag',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.bilibili.community.service.dm.v1.DanmakuFlagConfig',
      '10': 'flag'
    },
    {'1': 'specialDms', '3': 6, '4': 3, '5': 9, '10': 'specialDms'},
    {'1': 'checkBox', '3': 7, '4': 1, '5': 8, '10': 'checkBox'},
    {'1': 'count', '3': 8, '4': 1, '5': 3, '10': 'count'},
    {
      '1': 'commandDms',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.bilibili.community.service.dm.v1.CommandDm',
      '10': 'commandDms'
    },
    {
      '1': 'dmSetting',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.bilibili.community.service.dm.v1.DanmuWebPlayerConfig',
      '10': 'dmSetting'
    },
  ],
};

/// Descriptor for `DmWebViewReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dmWebViewReplyDescriptor = $convert.base64Decode(
    'Cg5EbVdlYlZpZXdSZXBseRIUCgVzdGF0ZRgBIAEoBVIFc3RhdGUSEgoEdGV4dBgCIAEoCVIEdG'
    'V4dBIaCgh0ZXh0U2lkZRgDIAEoCVIIdGV4dFNpZGUSQwoFZG1TZ2UYBCABKAsyLS5iaWxpYmls'
    'aS5jb21tdW5pdHkuc2VydmljZS5kbS52MS5EbVNlZ0NvbmZpZ1IFZG1TZ2USRwoEZmxhZxgFIA'
    'EoCzIzLmJpbGliaWxpLmNvbW11bml0eS5zZXJ2aWNlLmRtLnYxLkRhbm1ha3VGbGFnQ29uZmln'
    'UgRmbGFnEh4KCnNwZWNpYWxEbXMYBiADKAlSCnNwZWNpYWxEbXMSGgoIY2hlY2tCb3gYByABKA'
    'hSCGNoZWNrQm94EhQKBWNvdW50GAggASgDUgVjb3VudBJLCgpjb21tYW5kRG1zGAkgAygLMisu'
    'YmlsaWJpbGkuY29tbXVuaXR5LnNlcnZpY2UuZG0udjEuQ29tbWFuZERtUgpjb21tYW5kRG1zEl'
    'QKCWRtU2V0dGluZxgKIAEoCzI2LmJpbGliaWxpLmNvbW11bml0eS5zZXJ2aWNlLmRtLnYxLkRh'
    'bm11V2ViUGxheWVyQ29uZmlnUglkbVNldHRpbmc=');
