import 'package:Charta/store/reducer.dart';
import 'package:redux/redux.dart';

void rootMiddleware(Store<RootState> store, action, NextDispatcher next) {
  next(action);
}
