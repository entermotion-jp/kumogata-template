#
# Lambda permission resource
# http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-permission.html
#
require 'kumogata/template/helper'
require 'kumogata/template/iam'

name = _resource_name(args[:name], "lambda permission")
action = args[:action] || "lambda:*"
function = _ref_attr_string("function", "Arn", args, "lambda function", 'arn')
principal =
  case args[:principal]
  when /s3/
    's3.amazonaws.com'
  when /sns/
    'sns.amazonaws.com'
  else
    'sns.amazonaws.com'
  end
source_account = _ref_string("source_account", args, "account id")
source_account = _ref_pseudo('account id') if source_account.empty?
source_arn =
  if principal =~ /s3/
    _ref_attr_string('source_arn', 'Arn', args, 'bucket')
  else
    _ref_string("source_arn", args, 'topic')
  end
source_arn = _iam_arn("s3", { ref: args[:ref_iam_source_arn] }) if args.key? :ref_iam_source_arn and principal =~ /s3/ and source_arn.empty?
depends = _depends([ { ref_function: 'lambda function' } ], args)

_(name) do
  Type "AWS::Lambda::Permission"
  Properties do
    Action action
    FunctionName function
    Principal principal
    SourceAccount source_account unless source_account.empty?
    SourceArn source_arn unless source_arn.empty?
  end
  DependsOn depends unless depends.empty?
end
