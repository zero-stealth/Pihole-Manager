class QueryModel {
  // total queries
  final String dns_queries_today;
  final String ads_blocked_today;
  final String ads_percentage_today;
  final String domains_being_blocked;
  final String status;
  final String clients_ever_seen;

  QueryModel(
    this.dns_queries_today,
    this.ads_blocked_today,
    this.ads_percentage_today,
    this.domains_being_blocked,
    this.status,
    this.clients_ever_seen,
  );

  factory QueryModel.fromMap(Map json) {
    return QueryModel(
      json['dns_queries_today'],
      json['ads_blocked_today'],
      json['ads_percentage_today'],
      json['domains_being_blocked'],
      json['status'],
      json['clients_ever_seen'],
    );
  }
}
