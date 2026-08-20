import '../error/failures.dart';
import '../utils/either.dart';

// Base UseCase contract
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Marker class for parameterless operations
class NoParams {
  const NoParams();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NoParams;

  @override
  int get hashCode => 0;
}
