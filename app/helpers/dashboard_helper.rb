module DashboardHelper
  def status_badge_class(status)
    case status
    when "completed" then "bg-green-100 text-green-800"
    when "generating", "pending" then "bg-yellow-100 text-yellow-800"
    when "failed" then "bg-red-100 text-red-800"
    else "bg-gray-100 text-gray-800"
    end
  end
end
