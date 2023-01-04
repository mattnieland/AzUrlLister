class AzUrl {
  String? url;
  String? title;
  String? shortUrl;
  int? clicks;
  bool? isArchived;
  String? partitionKey;
  String? rowKey;
  String? timestamp;
  String? eTag;

  AzUrl(
      {this.url,
      this.title,
      this.shortUrl,
      this.clicks,
      this.isArchived,
      this.partitionKey,
      this.rowKey,
      this.timestamp,
      this.eTag});

  AzUrl.fromJson(Map<String, dynamic> json) {
    url = json['Url'];
    title = json['Title'];
    shortUrl = json['ShortUrl'];
    clicks = json['Clicks'];
    isArchived = json['IsArchived'];
    partitionKey = json['PartitionKey'];
    rowKey = json['RowKey'];
    timestamp = json['Timestamp'];
    eTag = json['ETag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Url'] = this.url;
    data['Title'] = this.title;
    data['ShortUrl'] = this.shortUrl;
    data['Clicks'] = this.clicks;
    data['IsArchived'] = this.isArchived;
    data['PartitionKey'] = this.partitionKey;
    data['RowKey'] = this.rowKey;
    data['Timestamp'] = this.timestamp;
    data['ETag'] = this.eTag;
    return data;
  }
}
