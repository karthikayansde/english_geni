import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'smart_buttons.dart';
import 'smart_form_field_theme.dart';

class SmartDropDown extends StatefulWidget {
  final String formControlName;
  final String labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isGreenWarnNeed;
  final Map<String, ValidationMessageFunction>? validationMessages;
  final void Function(List<String> selectedItems)? onChanged;
  final List<Map<String, String>> items;
  final bool isSingleDropDown;
  final bool singleSelectHasDeselect;
  final List<String>? initialSelectedItems;
  final bool isVertical;
  final bool removeXButtonOnChip;
  final String? searchHintText;
  final String? noItemsText;
  final String? selectAllText;
  final String? deselectAllText;
  final String? saveText;
  final String? cancelText;

  const SmartDropDown({
    super.key,
    required this.formControlName,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.isGreenWarnNeed = false,
    this.validationMessages,
    this.onChanged,
    required this.items,
    this.isSingleDropDown = false,
    this.singleSelectHasDeselect = false,
    this.initialSelectedItems,
    this.isVertical = false,
    this.removeXButtonOnChip = false,
    this.searchHintText,
    this.noItemsText,
    this.selectAllText,
    this.deselectAllText,
    this.saveText,
    this.cancelText,
  });

  @override
  State<SmartDropDown> createState() => _SmartDropDownState();
}

class _SmartDropDownState extends State<SmartDropDown> {
  late List<String> selectedItems;
  TextEditingController textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _getValueFromKey(String key) {
    for (var map in widget.items) {
      if (map.containsKey(key)) {
        return map[key] ?? key;
      }
    }
    return key;
  }

  void _updateTextController() {
    textEditingController.text =
        selectedItems.map((key) => _getValueFromKey(key)).join(', ');
  }

  @override
  void initState() {
    super.initState();
    selectedItems = List<String>.from(widget.initialSelectedItems ?? []);
    _updateTextController();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      (ReactiveForm.of(context) as FormGroup?)?.control(widget.formControlName).markAsTouched();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 450),
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: ReactiveStatusListenableBuilder(
          formControlName: widget.formControlName,
          builder: (context, control, child) {
            final isValid = control.valid;
            return ReactiveFormField<List<String>, List<String>>(
              formControlName: widget.formControlName,
              validationMessages: widget.validationMessages,
              builder: (ReactiveFormFieldState<List<String>, List<String>> field) {
                final values = field.value ?? [];
                
                // Sync local state with field value if they differ
                if (values.length != selectedItems.length || 
                    !values.every((v) => selectedItems.contains(v))) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        selectedItems = List<String>.from(values);
                        _updateTextController();
                      });
                    }
                  });
                }

                List<Widget> chipList = List.generate(
                  selectedItems.length,
                      (index) {
                    final item = selectedItems[index];
                    return Padding(
                      key: ValueKey(item),
                      padding: const EdgeInsets.only(right: 4),
                      child: Chip(
                        side: BorderSide(width: 1, color: Theme.of(context).colorScheme.outline),
                        key: ValueKey('chip-$item'),
                        label: Text(
                          _getValueFromKey(item),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        deleteIcon: widget.removeXButtonOnChip? null:const Icon(Icons.close, size: 16),
                        onDeleted: widget.removeXButtonOnChip? null:() {
                          setState(() {
                            selectedItems.remove(item);
                            _updateTextController();

                            // Update the ReactiveForm state
                            field.didChange(
                              List<String>.from(selectedItems),
                            );

                            if (widget.onChanged != null) {
                              widget.onChanged!(selectedItems);
                            }
                          });
                        },
                      ),
                    );
                  },
                ).toList();
                return TextFormField(
                  controller: textEditingController,
                  focusNode: _focusNode,
                  onTap: () async {
                    field.control.markAsTouched();
                    final selected = await showDialog<Set<String>>(
                      context: context,
                      builder: (context) {
                        return MultiDropDownDialog(
                          items: widget.items,
                          selectedItems: selectedItems,
                          labelText: widget.labelText,
                          isSingleDropDown: widget.isSingleDropDown,
                          singleSelectHasDeselect:
                          widget.singleSelectHasDeselect,
                        );
                      },
                    );
                    if (selected != null) {
                      setState(() {
                        selectedItems
                          ..clear()
                          ..addAll(selected);
                        _updateTextController();

                        // Update the ReactiveForm state
                        field.didChange(List<String>.from(selectedItems));

                        if (widget.onChanged != null) {
                          widget.onChanged!(selectedItems);
                        }
                      });
                    }
                  },
                  decoration: InputDecoration(
                    isDense: false,
                    prefixIcon: widget.prefixIcon,
                    errorText: field.errorText,
                    labelText: widget.labelText,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(SmartFormFieldTheme.radius),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          width: SmartFormFieldTheme.borderWidth,
                        ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SmartFormFieldTheme.radius),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                        width: SmartFormFieldTheme.borderWidth,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SmartFormFieldTheme.radius),
                      borderSide: BorderSide(
                        width: SmartFormFieldTheme.focusedBorderWidth,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SmartFormFieldTheme.radius),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: SmartFormFieldTheme.borderWidth,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SmartFormFieldTheme.radius),
                      borderSide: BorderSide(
                        width: SmartFormFieldTheme.focusedBorderWidth,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    prefix: Padding(
                      padding: EdgeInsets.only(
                        right: 30.0 + (widget.prefixIcon == null ? 0 : 35),
                      ),
                      child: widget.isVertical
                          ? SingleChildScrollView(
                        child: Wrap(children: chipList),
                      )
                          : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: chipList),
                      ),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.suffixIcon != null) widget.suffixIcon! else const Icon(Icons.keyboard_arrow_down_rounded, size: 24),
                        if (widget.isGreenWarnNeed && isValid && control.value != null && (control.value as List).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.check_circle, color: SmartFormFieldTheme.successColor),
                          ),
                      ],
                    ),
                  ),
                  readOnly: true,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  cursorColor: Colors.transparent,
                  style: const TextStyle(
                    color: Colors.transparent,
                    height: 0.0,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class MultiDropDownDialog extends StatefulWidget {
  final List<Map<String, String>> items;
  final List<String> selectedItems;
  final String? labelText;
  final bool isSingleDropDown;
  final bool singleSelectHasDeselect;

  final String? searchHintText;
  final String? noItemsText;
  final String? selectAllText;
  final String? deselectAllText;
  final String? saveText;
  final String? cancelText;

  const MultiDropDownDialog({
    super.key,
    required this.items,
    required this.selectedItems,
    this.labelText,
    required this.isSingleDropDown,
    required this.singleSelectHasDeselect,
    this.searchHintText,
    this.noItemsText,
    this.selectAllText,
    this.deselectAllText,
    this.saveText,
    this.cancelText,
  });

  @override
  State<MultiDropDownDialog> createState() => _MultiDropDownDialogState();
}

class _MultiDropDownDialogState extends State<MultiDropDownDialog> {
  final Set<String> _tempSelectedItems = {};
  List<Map<String, String>> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  String? _selectedItemKey;

  @override
  void initState() {
    super.initState();
    _tempSelectedItems.addAll(widget.selectedItems);
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
    if (widget.isSingleDropDown && _tempSelectedItems.isNotEmpty) {
      _selectedItemKey = _tempSelectedItems.first;
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        final itemValue = item.values.first;
        return itemValue.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      constraints: BoxConstraints(maxWidth: 350),
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsetsGeometry.all(16),
        child: Wrap(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'Select ${widget.labelText ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),

            widget.items.isNotEmpty
                ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.searchHintText ?? "Search...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SmartFormFieldTheme.radius),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            )
                : Container(
              margin: EdgeInsets.only(top: 30),
              height: 100, // Give it some height to be noticeable
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.noItemsText ?? 'No items available',
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                ],
              ),
            ),

            if (widget.items.isNotEmpty && !widget.isSingleDropDown)
              CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                visualDensity: const VisualDensity(vertical: -1.5),
                // activeColor: Theme.of(context).primaryColor,
                value: _tempSelectedItems.length == widget.items.length,
                title: Text(
                  _tempSelectedItems.length == widget.items.length
                      ? (widget.deselectAllText ?? "Deselect All")
                      : (widget.selectAllText ?? "Select All"),
                ),
                onChanged: (v) {
                  setState(() {
                    if (!v!) {
                      _tempSelectedItems.clear();
                    } else {
                      _tempSelectedItems.addAll(
                        widget.items.map((item) => item.keys.first),
                      );
                    }
                  });
                },
              ),
            if (widget.items.isNotEmpty && !widget.isSingleDropDown)
              Container(
                height: 1,
                color: Colors.grey,
                margin: EdgeInsetsGeometry.only(bottom: 4, left: 4, right: 4),
              ),
            Container(
              constraints: const BoxConstraints(maxHeight: 250, minHeight: 80),
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  if (!widget.isSingleDropDown)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final item = _filteredItems[index];
                          return CheckboxListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            visualDensity: const VisualDensity(vertical: -1.5),
                            value: _tempSelectedItems.contains(item.keys.first),
                            title: Text(item.values.first),
                            // activeColor: Theme.of(context).primaryColor,
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _tempSelectedItems.add(item.keys.first);
                                } else {
                                  _tempSelectedItems.remove(item.keys.first);
                                }
                              });
                            },
                          );
                        },
                        childCount: _filteredItems.length,
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final item = _filteredItems[index];
                          final itemKey = item.keys.first;
                          final itemValue = item.values.first;
                          final isSelected = _selectedItemKey == itemKey;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            visualDensity: const VisualDensity(vertical: -1.5),
                            leading: Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected ? Theme.of(context).colorScheme.primary : null,
                            ),
                            title: Text(itemValue),
                            onTap: () {
                              setState(() {
                                if (widget.singleSelectHasDeselect &&
                                    (_selectedItemKey == itemKey)) {
                                  _selectedItemKey = null;
                                  _tempSelectedItems.clear();
                                } else {
                                  _selectedItemKey = itemKey;
                                  _tempSelectedItems.clear();
                                  _tempSelectedItems.add(itemKey);
                                }
                              });
                            },
                          );
                        },
                        childCount: _filteredItems.length,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(
                    widget.cancelText ?? 'Cancel',
                  ),
                ),
                const SizedBox(width: 8),
                SmartPrimaryButton(
                  height: 35,
                  width: 100,
                  onPressed: () async => Navigator.of(context).pop(_tempSelectedItems),
                  label: widget.saveText ?? 'Save',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// usage

// final FormGroup form = FormGroup({
//   'categories': FormControl<List<String>>(
//     value: [],
//     validators: [Validators.minLength(1)],
//   ),
// });
//
// SmartDropDown(
// formControlName: "categories",
// items: [
// {"1": "Quarter 1"},
// {"2": "Quarter 2"},
// {"3": "Quarter 3"},
// {"4": "Quarter 4"},
// {"5": "Quarter 11"},
// {"6": "Quarter 12"},
// {"7": "Quarter 13"},
// {"8": "Quarter 14"},
// {"9": "Quarter 12334"},
// {"12": "Quarter 13422"},
// {"13": "Quarter 11233"},
// {"14": "Quarter 41324"},
// ],
// isVertical: true,
// prefixIcon: Icon(Icons.calendar_month, size: 30),
// labelText: "Quarter",isSingleDropDown: true,
// onSelectionChanged: (selectedItems) {
// print(selectedItems);
// },
// ),