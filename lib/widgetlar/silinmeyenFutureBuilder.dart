import 'package:flutter/material.dart';

class SilinmeyenFutureBuilder extends StatefulWidget {
  final Future future;
  final AsyncWidgetBuilder builder;

  const SilinmeyenFutureBuilder({Key key, this.future, this.builder}) : super(key: key);

  @override
  _SilinmeyenFutureBuilderState createState() => _SilinmeyenFutureBuilderState();
}

class _SilinmeyenFutureBuilderState extends State<SilinmeyenFutureBuilder> with AutomaticKeepAliveClientMixin<SilinmeyenFutureBuilder> {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: widget.future,
      builder: widget.builder
      );
  }
}