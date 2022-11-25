import 'package:flutter/material.dart';

import '../../widgets/linear_percent_indicator.dart';

// ignore: must_be_immutable
class Polls extends StatefulWidget {
  Polls({
    required this.children,
    required this.pollTitle,
    this.hasVoted,
    this.controller,
    this.onVote,
    this.outlineColor = Colors.blue,
    this.backgroundColor = Colors.blueGrey,
    this.onVoteBackgroundColor = Colors.blue,
    this.leadingPollStyle,
    this.pollStyle,
    this.iconColor = Colors.black,
    this.leadingBackgroundColor = Colors.blueGrey,
    this.barRadius = 10,
    this.userChoiceIcon,
    this.showLogger = true,
    this.totalVotes = 0,
    this.userPollChoice,
    Key? key,
  }) : super(key: key);

  final double barRadius;
  int? userPollChoice;

  final int totalVotes;

  final Text pollTitle;
  final Widget? userChoiceIcon;

  final bool? hasVoted;
  final bool showLogger;

  // final PollHighest? getHighest;
  final PollOnVote? onVote;
  List<PollOption> children;
  final PollController? controller;

  /// style
  final TextStyle? pollStyle;
  final TextStyle? leadingPollStyle;

  ///colors setting for polls widget
  final Color outlineColor;
  final Color backgroundColor;
  final Color? onVoteBackgroundColor;
  final Color? iconColor;
  final Color? leadingBackgroundColor;

  @override
  PollsState createState() => PollsState();
}

class PollsState extends State<Polls> {
  // var logger = Logger();
  PollController? _controller;

  var choiceList = <String>[];
  var userChoiceList = <String>[];
  var valueList = <double>[];
  var userValueList = <double>[];

  /// style
  late TextStyle pollStyle;
  late TextStyle leadingPollStyle;

  ///colors setting for polls widget
  Color? outlineColor;
  Color? backgroundColor;
  Color? onVoteBackgroundColor;
  Color? iconColor;
  Color? leadingBackgroundColor;

  double highest = 0.0;

  bool hasVoted = false;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller;
    _controller ??= PollController();
    _controller!.children = widget.children;
    hasVoted = widget.hasVoted ?? _controller!.hasVoted;

    _controller?.addListener(() {
      if (_controller!.makeChange) {
        hasVoted = _controller!.hasVoted;
        _updateView();
      }
    });

    _reCalibrate();
  }

  void _updateView() {
    widget.children = _controller!.children;
    _controller!.revertChangeBoolean();
    _reCalibrate();
  }

  void _reCalibrate() {
    choiceList.clear();
    userChoiceList.clear();
    valueList.clear();

    /// if polls style is null, it sets default pollstyle and leading pollstyle
    pollStyle = widget.pollStyle ??
        const TextStyle(color: Colors.black, fontWeight: FontWeight.w300);
    leadingPollStyle = widget.leadingPollStyle ??
        const TextStyle(color: Colors.black, fontWeight: FontWeight.w800);

    widget.children.map((e) {
      choiceList.add(e.option);
      userChoiceList.add(e.option);
      valueList.add(e.value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!hasVoted) {
      //user can cast vote with this widget
      return voterWidget(context);
    } else {
      //user can view his votes with this widget
      return voteCasted(context);
    }
  }

  /// voterWidget creates view for users to cast their votes
  Widget voterWidget(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.pollTitle,
        const SizedBox(
          height: 12,
        ),
        Column(
          children: widget.children.map((element) {
            int index = widget.children.indexOf(element);
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                margin: const EdgeInsets.all(0),
                width: MediaQuery.of(context).size.width / 1.5,
                padding: const EdgeInsets.all(0),
                // height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: widget.backgroundColor,
                ),
                child: OutlinedButton(
                  onPressed: () {
                    widget.onVote!(
                      widget.children[index],
                      index,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.outlineColor,
                    padding: const EdgeInsets.all(5.0),
                    side: BorderSide(
                      color: widget.outlineColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(widget.barRadius),
                    ),
                  ),
                  child: Text(
                    element.option,
                    style: widget.pollStyle,
                    maxLines: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// voteCasted created view for user to see votes they casted including other peoples vote
  Widget voteCasted(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.pollTitle,
        const SizedBox(
          height: 12,
        ),
        Column(
          children: widget.children.map(
            (element) {
              int index = widget.children.indexOf(element);
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                width: double.infinity,
                child: LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  animation: true,
                  lineHeight: 38.0,
                  animationDuration: 500,
                  percent:
                      PollMethods.getViewPercentage(valueList, index + 1, 1),
                  center: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              choiceList[index].toString(),
                              style: highest == valueList[index]
                                  ? widget.leadingPollStyle
                                  : widget.pollStyle,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            userChoice(
                              widget.userPollChoice,
                              index + 1,
                              widget.userChoiceIcon ??
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: 17,
                                  ),
                            )
                          ],
                        ),
                        Text(
                          "${PollMethods.getViewPercentage(valueList, index + 1, 100).toStringAsFixed(1)}%",
                          style: highest == valueList[index]
                              ? widget.leadingPollStyle
                              : widget.pollStyle,
                        )
                      ],
                    ),
                  ),
                  barRadius: Radius.circular(widget.barRadius),
                  progressColor: highest == valueList[index]
                      ? widget.leadingBackgroundColor
                      : widget.onVoteBackgroundColor,
                ),
              );
            },
          ).toList(),
        )
      ],
    );
  }
}

Widget userChoice(int? choice, int? index, Widget icon) {
  if (choice != null) {
    if (choice == index) {
      return icon;
    }
  }
  return Container();
}

class PollMethods {
  static double getViewPercentage(List<double> valueList, choice, int byValue) {
    double div = 0.0;
    var slot = <double>[];
    double sum = 0.0;

    valueList.map((element) {
      slot.add(element);
    }).toList();

    valueList.map((element) {
      sum = slot.map((value) => value).fold(0, (a, b) => a + b);
    }).toList();
    div = sum == 0 ? 0.0 : (byValue / sum) * slot[choice - 1];
    return div;
  }
}

class PollOption {
  String? optionId;
  String option;
  double value;

  PollOption({
    this.optionId,
    required this.option,
    required this.value,
  });
}

class PollController extends ChangeNotifier {
  var children = <PollOption>[];
  bool hasVoted = false;
  bool makeChange = false;

  void revertChangeBoolean() {
    makeChange = false;
    notifyListeners();
  }
}

typedef PollOnVote = void Function(
  PollOption pollOption,
  int optionIndex,
);
