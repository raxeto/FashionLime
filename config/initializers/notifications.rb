# ActiveSupport::Notifications.subscribe "render_template.action_view" do |name, start, finish, id, payload|
#     duration = (finish - start) * 1000
#     Rails.logger.info("rendered #{payload[:identifier]} with layout #{payload[:layout]} for #{duration} ms")
# end

# ActiveSupport::Notifications.subscribe "render_partial.action_view" do |name, start, finish, id, payload|
#     duration = (finish - start) * 1000
#     Rails.logger.info("rendered partial #{payload[:identifier]} for #{duration} ms")
# end

# ActiveSupport::Notifications.subscribe "render_collection.action_view" do |name, start, finish, id, payload|
#     duration = (finish - start) * 1000
#     Rails.logger.info("rendered collection #{payload[:identifier]} of #{payload[:count]} items for #{duration} ms cache hits #{payload[:cache_hits]}")
# end
