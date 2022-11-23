import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Polls extends StatefulWidget {
  Polls({
    required this.children,
    required this.question,
    this.hasVoted,
    this.userId,
    this.controller,
    this.onVote,
    this.outlineColor = Colors.blue,
    this.backgroundColor = Colors.blueGrey,
    this.onVoteBackgroundColor = Colors.blue,
    this.leadingPollStyle,
    this.pollStyle,
    this.iconColor = Colors.black,
    this.leadingBackgroundColor = Colors.blueGrey,
    this.getHighest,
    this.barRadius = 10,
    this.userChoiceIcon,
    this.showLogger = true,
    this.totalVotes = 0,
    Key? key,
  }) : super(key: key);

  final String? userId;
  final double barRadius;

  final int totalVotes;

  final Text question;
  final Widget? userChoiceIcon;

  final bool? hasVoted;
  final bool showLogger;

  final PollHighest? getHighest;
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
  _PollsState createState() => _PollsState();
}

class _PollsState extends State<Polls> {
  // var logger = Logger();
  PollController? _controller;
  int? _userPollChoice;

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

    // if (widget.showLogger) logger.i([widget.question, widget.children]);
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
        widget.question,
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
                    // setState(() {
                    //   _userPollChoice = index;
                    // });
                    // _controller!.updatePollOption(index);
                    // double total = PollMethods.getTotalVotes(valueList);
                    // print('here');
                    // print(widget.children);
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
    var sortedKeys = <double>[];

    valueList.map((e) {
      sortedKeys.add(e);
    }).toList();

    //sort valueList
    sortedKeys.sort((a, b) => a.compareTo(b));

    double current = 0;

    for (var i = 0; i < sortedKeys.length; i++) {
      double s = double.parse(sortedKeys[i].toString());
      if (sortedKeys[i] >= current) {
        current = s;
      }
    }

    // highest = current;
    // widget.getHighest!(highest.toStringAsFixed(1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.question,
        const SizedBox(
          height: 12,
        ),
        Column(
          children: widget.children.map((element) {
            int index = widget.children.indexOf(element);
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              width: double.infinity,
              child: LinearPercentIndicator(
                padding: EdgeInsets.zero,
                animation: true,
                lineHeight: 38.0,
                animationDuration: 500,
                percent: PollMethods.getViewPercentage(valueList, index + 1, 1),
                center: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(choiceList[index].toString(),
                              style: highest == valueList[index]
                                  ? widget.leadingPollStyle
                                  : widget.pollStyle),
                          const SizedBox(
                            width: 10,
                          ),
                          userChoice(
                              _userPollChoice,
                              index + 1,
                              widget.userChoiceIcon ??
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: 17,
                                  ))
                        ],
                      ),
                      Text(
                          "${PollMethods.getViewPercentage(valueList, index + 1, 100).toStringAsFixed(1)}%",
                          style: highest == valueList[index]
                              ? widget.leadingPollStyle
                              : widget.pollStyle)
                    ],
                  ),
                ),
                barRadius: Radius.circular(widget.barRadius),
                progressColor: highest == valueList[index]
                    ? widget.leadingBackgroundColor
                    : widget.onVoteBackgroundColor,
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}

Widget userChoice(choice, index, Widget icon) {
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

  // static getTotalVotes(List<double> valueList) {
  //   double sum = 0.0;

  //   sum = valueList.map((value) => value).fold(0, (a, b) => a + b);

  //   return sum;
  // }
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

  void updatePollOption(int index) {
    if (children.isNotEmpty) {
      children[index].value += 1;
      makeChange = true;
      hasVoted = true;
    }
    notifyListeners();
  }

  void revertChangeBoolean() {
    makeChange = false;
    notifyListeners();
  }
}

// enum PollType {
//   creator,
//   voter,
//   readOnly,
// }

typedef PollOnVote = void Function(
  PollOption pollOption,
  int optionIndex,
);

typedef PollHighest = void Function(String total);

class LinearPercentIndicator extends StatefulWidget {
  ///Percent value between 0.0 and 1.0
  final double percent;
  final double? width;

  ///Height of the line
  final double lineHeight;

  ///Color of the background of the Line , default = transparent
  final Color fillColor;

  ///First color applied to the complete line
  Color get backgroundColor => _backgroundColor;
  late Color _backgroundColor;

  ///First color applied to the complete line
  final LinearGradient? linearGradientBackgroundColor;

  Color get progressColor => _progressColor;

  late Color _progressColor;

  ///true if you want the Line to have animation
  final bool animation;

  ///duration of the animation in milliseconds, It only applies if animation attribute is true
  final int animationDuration;

  ///widget at the left of the Line
  final Widget? leading;

  ///widget at the right of the Line
  final Widget? trailing;

  ///widget inside the Line
  final Widget? center;

  ///The kind of finish to place on the end of lines drawn, values supported: butt, round, roundAll
  // @Deprecated('This property is no longer used, please use barRadius instead.')
  // final LinearStrokeCap? linearStrokeCap;

  /// The border radius of the progress bar (Will replace linearStrokeCap)
  final Radius? barRadius;

  ///alignment of the Row (leading-widget-center-trailing)
  final MainAxisAlignment alignment;

  ///padding to the LinearPercentIndicator
  final EdgeInsets padding;

  /// set true if you want to animate the linear from the last percent value you set
  final bool animateFromLastPercent;

  /// If present, this will make the progress bar colored by this gradient.
  ///
  /// This will override [progressColor]. It is an error to provide both.
  final LinearGradient? linearGradient;

  /// set false if you don't want to preserve the state of the widget
  final bool addAutomaticKeepAlive;

  /// set true if you want to animate the linear from the right to left (RTL)
  final bool isRTL;

  /// Creates a mask filter that takes the progress shape being drawn and blurs it.
  final MaskFilter? maskFilter;

  /// Set true if you want to display only part of [linearGradient] based on percent value
  /// (ie. create 'VU effect'). If no [linearGradient] is specified this option is ignored.
  final bool clipLinearGradient;

  /// set a linear curve animation type
  final Curve curve;

  /// set true when you want to restart the animation, it restarts only when reaches 1.0 as a value
  /// defaults to false
  final bool restartAnimation;

  /// Callback called when the animation ends (only if `animation` is true)
  final VoidCallback? onAnimationEnd;

  /// Display a widget indicator at the end of the progress. It only works when `animation` is true
  final Widget? widgetIndicator;

  LinearPercentIndicator({
    Key? key,
    this.fillColor = Colors.transparent,
    this.percent = 0.0,
    this.lineHeight = 5.0,
    this.width,
    Color? backgroundColor,
    this.linearGradientBackgroundColor,
    this.linearGradient,
    Color? progressColor,
    this.animation = false,
    this.animationDuration = 500,
    this.animateFromLastPercent = false,
    this.isRTL = false,
    this.leading,
    this.trailing,
    this.center,
    this.addAutomaticKeepAlive = true,
    // this.linearStrokeCap,
    this.barRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 10.0),
    this.alignment = MainAxisAlignment.start,
    this.maskFilter,
    this.clipLinearGradient = false,
    this.curve = Curves.linear,
    this.restartAnimation = false,
    this.onAnimationEnd,
    this.widgetIndicator,
  }) : super(key: key) {
    if (linearGradient != null && progressColor != null) {
      throw ArgumentError(
          'Cannot provide both linearGradient and progressColor');
    }
    _progressColor = progressColor ?? Colors.red;

    if (linearGradientBackgroundColor != null && backgroundColor != null) {
      throw ArgumentError(
          'Cannot provide both linearGradientBackgroundColor and backgroundColor');
    }
    _backgroundColor = backgroundColor ?? const Color(0xFFB8C7CB);

    if (percent < 0.0 || percent > 1.0) {
      throw Exception(
          "Percent value must be a double between 0.0 and 1.0, but it's $percent");
    }
  }

  @override
  _LinearPercentIndicatorState createState() => _LinearPercentIndicatorState();
}

class _LinearPercentIndicatorState extends State<LinearPercentIndicator>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController? _animationController;
  Animation? _animation;
  double _percent = 0.0;
  final _containerKey = GlobalKey();
  final _keyIndicator = GlobalKey();
  double _containerWidth = 0.0;
  double _containerHeight = 0.0;
  double _indicatorWidth = 0.0;
  double _indicatorHeight = 0.0;

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _containerWidth = _containerKey.currentContext?.size?.width ?? 0.0;
          _containerHeight = _containerKey.currentContext?.size?.height ?? 0.0;
          if (_keyIndicator.currentContext != null) {
            _indicatorWidth = _keyIndicator.currentContext?.size?.width ?? 0.0;
            _indicatorHeight =
                _keyIndicator.currentContext?.size?.height ?? 0.0;
          }
        });
      }
    });
    if (widget.animation) {
      _animationController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.animationDuration));
      _animation = Tween(begin: 0.0, end: widget.percent).animate(
        CurvedAnimation(parent: _animationController!, curve: widget.curve),
      )..addListener(() {
          setState(() {
            _percent = _animation!.value;
          });
          if (widget.restartAnimation && _percent == 1.0) {
            _animationController!.repeat(min: 0, max: 1.0);
          }
        });
      _animationController!.addStatusListener((status) {
        if (widget.onAnimationEnd != null &&
            status == AnimationStatus.completed) {
          widget.onAnimationEnd!();
        }
      });
      _animationController!.forward();
    } else {
      _updateProgress();
    }
    super.initState();
  }

  void _checkIfNeedCancelAnimation(LinearPercentIndicator oldWidget) {
    if (oldWidget.animation &&
        !widget.animation &&
        _animationController != null) {
      _animationController!.stop();
    }
  }

  @override
  void didUpdateWidget(LinearPercentIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent) {
      if (_animationController != null) {
        _animationController!.duration =
            Duration(milliseconds: widget.animationDuration);
        _animation = Tween(
                begin: widget.animateFromLastPercent ? oldWidget.percent : 0.0,
                end: widget.percent)
            .animate(
          CurvedAnimation(parent: _animationController!, curve: widget.curve),
        );
        _animationController!.forward(from: 0.0);
      } else {
        _updateProgress();
      }
    }
    _checkIfNeedCancelAnimation(oldWidget);
  }

  _updateProgress() {
    setState(() {
      _percent = widget.percent;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var items = List<Widget>.empty(growable: true);
    if (widget.leading != null) {
      items.add(widget.leading!);
    }
    final hasSetWidth = widget.width != null;
    final percentPositionedHorizontal =
        _containerWidth * _percent - _indicatorWidth / 3;
    var containerWidget = Container(
      width: hasSetWidth ? widget.width : double.infinity,
      height: widget.lineHeight,
      padding: widget.padding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            key: _containerKey,
            painter: _LinearPainter(
              isRTL: widget.isRTL,
              progress: _percent,
              progressColor: widget.progressColor,
              linearGradient: widget.linearGradient,
              backgroundColor: widget.backgroundColor,
              barRadius: widget.barRadius ??
                  Radius.zero, // If radius is not defined, set it to zero
              linearGradientBackgroundColor:
                  widget.linearGradientBackgroundColor,
              maskFilter: widget.maskFilter,
              clipLinearGradient: widget.clipLinearGradient,
            ),
            child: (widget.center != null)
                ? Center(child: widget.center)
                : Container(),
          ),
          if (widget.widgetIndicator != null && _indicatorWidth == 0)
            Opacity(
              opacity: 0.0,
              key: _keyIndicator,
              child: widget.widgetIndicator,
            ),
          if (widget.widgetIndicator != null &&
              _containerWidth > 0 &&
              _indicatorWidth > 0)
            Positioned(
              right: widget.isRTL ? percentPositionedHorizontal : null,
              left: !widget.isRTL ? percentPositionedHorizontal : null,
              top: _containerHeight / 2 - _indicatorHeight,
              child: widget.widgetIndicator!,
            ),
        ],
      ),
    );

    if (hasSetWidth) {
      items.add(containerWidget);
    } else {
      items.add(Expanded(
        child: containerWidget,
      ));
    }
    if (widget.trailing != null) {
      items.add(widget.trailing!);
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        color: widget.fillColor,
        child: Row(
          mainAxisAlignment: widget.alignment,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: items,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => widget.addAutomaticKeepAlive;
}

class _LinearPainter extends CustomPainter {
  final Paint _paintBackground = Paint();
  final Paint _paintLine = Paint();
  final double progress;
  final bool isRTL;
  final Color progressColor;
  final Color backgroundColor;
  final Radius barRadius;
  final LinearGradient? linearGradient;
  final LinearGradient? linearGradientBackgroundColor;
  final MaskFilter? maskFilter;
  final bool clipLinearGradient;

  _LinearPainter({
    required this.progress,
    required this.isRTL,
    required this.progressColor,
    required this.backgroundColor,
    required this.barRadius,
    this.linearGradient,
    this.maskFilter,
    required this.clipLinearGradient,
    this.linearGradientBackgroundColor,
  }) {
    _paintBackground.color = backgroundColor;

    _paintLine.color = progress.toString() == "0.0"
        ? progressColor.withOpacity(0.0)
        : progressColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background first
    Path backgroundPath = Path();
    backgroundPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), barRadius));
    canvas.drawPath(backgroundPath, _paintBackground);
    canvas.clipPath(backgroundPath);

    if (maskFilter != null) {
      _paintLine.maskFilter = maskFilter;
    }

    if (linearGradientBackgroundColor != null) {
      Offset shaderEndPoint =
          clipLinearGradient ? Offset.zero : Offset(size.width, size.height);
      _paintBackground.shader = linearGradientBackgroundColor
          ?.createShader(Rect.fromPoints(Offset.zero, shaderEndPoint));
    }

    // Then draw progress line
    final xProgress = size.width * progress;
    Path linePath = Path();
    if (isRTL) {
      if (linearGradient != null) {
        _paintLine.shader = _createGradientShaderRightToLeft(size, xProgress);
      }
      linePath.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(
              size.width - size.width * progress, 0, xProgress, size.height),
          barRadius));
    } else {
      if (linearGradient != null) {
        _paintLine.shader = _createGradientShaderLeftToRight(size, xProgress);
      }
      linePath.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, xProgress, size.height), barRadius));
    }
    canvas.drawPath(linePath, _paintLine);
  }

  Shader _createGradientShaderRightToLeft(Size size, double xProgress) {
    Offset shaderEndPoint =
        clipLinearGradient ? Offset.zero : Offset(xProgress, size.height);
    return linearGradient!.createShader(
      Rect.fromPoints(
        Offset(size.width, size.height),
        shaderEndPoint,
      ),
    );
  }

  Shader _createGradientShaderLeftToRight(Size size, double xProgress) {
    Offset shaderEndPoint = clipLinearGradient
        ? Offset(size.width, size.height)
        : Offset(xProgress, size.height);
    return linearGradient!.createShader(
      Rect.fromPoints(
        Offset.zero,
        shaderEndPoint,
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
