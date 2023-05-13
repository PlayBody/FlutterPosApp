import 'package:flutter/material.dart';

var dropdownDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  isDense: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      width: 1,
      color: Color(0xffbebebe),
    ),
  ),
  contentPadding: EdgeInsets.fromLTRB(8, 12, 0, 12),
);

class DropDownNumberSelect extends StatelessWidget {
  final String? value;
  final int? diff;
  final int? min;
  final int? plusnum;
  final bool? isPlusLabel;
  final contentPadding;
  final int max;
  final String? hint;
  final tapFunc;
  final String? label;
  final String? caption;
  final bool? isAddNull;
  const DropDownNumberSelect(
      {this.value,
      required this.max,
      required this.tapFunc,
      this.diff,
      this.plusnum,
      this.isPlusLabel,
      this.contentPadding,
      this.min,
      this.hint,
      this.label,
      this.caption,
      this.isAddNull,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> itemList = [];
    int start = min == null ? 1 : min!;
    int dff = diff == null ? 1 : diff!;
    for (var i = start; i <= max; i = i + dff) {
      itemList.add(
          i.toString() + ((isPlusLabel == null || !isPlusLabel!) ? '' : '+'));
    }

    if (plusnum != null) {
      for (var i = 1; i <= plusnum!; i++) {
        itemList.add('+$i');
      }
    }

    return DropdownButtonFormField(
      isExpanded: true,
      hint: Text(hint == null ? '' : hint!),
      decoration: InputDecoration(
        label: caption == null
            ? null
            : Text(
                caption!,
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
        fillColor: Colors.white,
        filled: true,
        isDense: true,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Color(0xffbebebe),
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Color(0xffbebebe),
          ),
        ),
        contentPadding: contentPadding ?? const EdgeInsets.fromLTRB(8, 6, 0, 6),
      ),
      value: value,
      items: [
        if (isAddNull != null && isAddNull!)
          const DropdownMenuItem(
            value: null,
            child: Text('なし'),
          ),
        ...itemList.map((e) => DropdownMenuItem(
              value: e,
              child: Text(e + (label == null ? '' : label!),
                  textAlign: TextAlign.right),
            ))
      ],
      onChanged: tapFunc,
    );
  }
}

class DropDownModelSelect extends StatelessWidget {
  final dynamic value;
  final List<DropdownMenuItem> items;
  final contentPadding;
  final String? hint;
  final String? caption;
  final dropdownState;
  final tapFunc;
  const DropDownModelSelect(
      {this.value,
      required this.items,
      this.dropdownState,
      this.contentPadding,
      required this.tapFunc,
      this.caption,
      this.hint,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      key: dropdownState,
      isExpanded: true,
      hint: Text(hint == null ? '' : hint!),
      decoration: InputDecoration(
        label: caption == null
            ? null
            : Text(
                caption!,
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
        fillColor: Colors.white,
        filled: true,
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Color(0xffbebebe),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Color(0xffbebebe),
          ),
        ),
        contentPadding: contentPadding == null
            ? EdgeInsets.fromLTRB(8, 6, 0, 6)
            : contentPadding,
      ),
      value: value,
      items: items,
      onChanged: tapFunc,
    );
  }
}
