analyze:
	flutter pub get
	dart fix --apply
	dart analyze
	dart run dart_code_metrics:metrics lib
	dart run dart_code_metrics:check-unused-code lib
	dart run dart_code_metrics:check-duplicate-code lib