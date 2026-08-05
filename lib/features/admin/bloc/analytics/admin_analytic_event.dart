
abstract class AdminAnalyticsEvent {}

class FetchAdminAnalytics extends AdminAnalyticsEvent {
  final String period;
  FetchAdminAnalytics({this.period = '30d'});
}