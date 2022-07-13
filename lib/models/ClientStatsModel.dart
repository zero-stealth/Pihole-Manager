class ClientStatsModel {
  // total queries
  final String dns_queries_today;

  ClientStatsModel(
    this.dns_queries_today,
  );

  factory ClientStatsModel.fromMap(Map json) {
    return ClientStatsModel(
      json['top_sources'][''],
    );
  }
}
