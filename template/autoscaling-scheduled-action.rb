#
# Autoscaling ScheduledAction resource
# http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-as-scheduledaction.html
#
require 'kumogata/template/helper'

name = _resource_name(args[:name], "autoscaling scheduled action")
autoscaling = _ref_string("autoscaling", args, "autoscaling group")
autoscaling = _ref_resource_name(args, "autoscaling group") if autoscaling.empty?
desired = _integer("desired", args, -1)
end_time =
  if args.key? :end_time
    _timestamp_utc(args[:end_time])
  else
    ""
  end
max = _integer("max", args, -1)
max = desired if max < desired
min = _integer("min", args, -1)
min = desired if min < desired

recurrence =
  if args.key? :recurrence
    case args[:recurrence]
    when "every 5 min"
      "*/5 * * * *"
    when "every 30 min"
      "0,30 * * * *"
    when "every 1 hour"
      "0 * * * *"
    when "every day"
      "0 0 * * *"
    when "every week"
      "0 0 * * Tue"
    when /\*/
      args[:recurrence]
    else
      _timestamp_utc(args[:recurrence], "cron")
    end
  else
    ""
  end
start_time =
  if args.key? :start_time
    _timestamp_utc(args[:start_time])
  else
    _timestamp_utc(Time.now + 3600)
  end

_(name) do
  Type "AWS::AutoScaling::ScheduledAction"
  Properties do
    AutoScalingGroupName autoscaling
    DesiredCapacity desired if desired > -1
    EndTime end_time unless end_time.empty?
    MaxSize max if max > -1
    MinSize min if min > -1
    Recurrence recurrence unless recurrence.empty?
    StartTime start_time unless start_time.empty?
  end
end
