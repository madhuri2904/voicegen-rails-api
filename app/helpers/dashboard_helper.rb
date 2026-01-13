module DashboardHelper
  def status_badge_class(status)
    case status
    when "completed"
      "bg-green-100 text-green-800"
    when "processing", "pending"
      "bg-yellow-100 text-yellow-800"
    when "failed"
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end
