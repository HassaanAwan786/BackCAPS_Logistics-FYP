class Job {
  late String jobRequest;
  late String jobRequestTo;
  late String jobType;
  late String startDate;
  late String status;

  Job({
    required this.jobRequest,
    required this.jobRequestTo,
    required this.jobType,
    required this.startDate,
    required this.status,
  });

  factory Job.fromJson(Map<String, dynamic> json) => Job(
    jobRequest: json['jobRequest'] ?? 'NULL',
    jobRequestTo: json['jobRequestTo'] ?? 'NULL',
    jobType: json['jobType'] ?? "NULL",
    startDate: json['startDate'] ?? 'NULL',
    status: json['status'] ?? 'NULL',
  );

  Map<String, dynamic> toJson() => {
    'jobRequest': jobRequest,
    'jobRequestTo': jobRequestTo,
    'jobType': jobType,
    'startDate': startDate,
    'status': status,
  };
}
