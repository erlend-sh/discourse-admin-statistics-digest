require_relative '../admin_statistics_digest/base_report'

class AdminStatisticsDigest::ActiveUser < AdminStatisticsDigest::BaseReport
  provide_filter :months_ago

  def to_sql
    <<~SQL
WITH periods AS (
SELECT
months_ago,
date_trunc('month', CURRENT_DATE) - INTERVAL '1 months' * months_ago AS period_start,
date_trunc('month', CURRENT_DATE) - INTERVAL '1 months' * months_ago + INTERVAL '1 month' - INTERVAL '1 second' AS period_end
FROM unnest(ARRAY #{filters.months_ago}) as months_ago
),
visiting_users AS (
SELECT
DISTINCT uv.user_id,
p.months_ago
FROM user_visits uv
RIGHT JOIN periods p
ON uv.visited_at >= p.period_start
AND uv.visited_at <= p.period_end
)

SELECT
vu.months_ago,
count(vu.user_id) as active_users
FROM visiting_users vu
GROUP BY vu.months_ago
ORDER BY vu.months_ago
SQL
  end
end
