import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../display.dart';
import '../global_state.dart';

class TeamOptionsPage extends StatelessWidget {
  static const route = "/teams";
  const TeamOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: DisplayCharacterstics.forSize(MediaQuery.sizeOf(context)),
      builder: _subTreeBuilder,
    );
  }

  Widget _subTreeBuilder(BuildContext context, _child) {
    final scoreboard = context.watch<GlobalScoreboard>();
    final _tempTeams = List.generate(
      scoreboard.teamCount,
      (index) => _TeamData(
        scoreboard.getTeamName(index),
        scoreboard.getTeamColor(index),
      ),
    );

    return _TeamOptionsContent(tempTeams: _tempTeams);
  }
}

class _TeamData {
  String name;
  Color seedColor;
  late ColorScheme colorScheme;

  _TeamData(this.name, this.seedColor) {
    this.colorScheme = deriveColorScheme(this.seedColor);
  }

  void setSeedColor(Color newSeedColor) {
    this.seedColor = newSeedColor;
    this.colorScheme = deriveColorScheme(this.seedColor);
  }
}

class _TeamOptionsContent extends StatefulWidget {
  final List<_TeamData> tempTeams;
  const _TeamOptionsContent({required this.tempTeams});

  @override
  State<_TeamOptionsContent> createState() => _TeamOptionsContentState();
}

class _TeamOptionsContentState extends State<_TeamOptionsContent> {
  late List<_TeamData> _tempTeams;
  int? _editingNameId; // Index of card currently typing text

  @override
  void initState() {
    super.initState();
    _tempTeams = widget.tempTeams;
  }

  @override
  void didUpdateWidget(covariant _TeamOptionsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tempTeams.length != _tempTeams.length) {
      // Team count changed, update local state
      // We might lose unsaved edits here if we strictly overwrite,
      // but since we save before add/remove, it should be fine.
      _tempTeams = widget.tempTeams;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayCharacterstics = context.read<DisplayCharacterstics>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scoreboard = context.watch<GlobalScoreboard>();

    // Background: Solid, very light grey (#F4F6F8)
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          'Settings',
          textScaler: displayCharacterstics.compundedTextScaler(scale: 1.1),
        ),
        titleTextStyle: theme.textTheme.displaySmall!.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
        toolbarHeight: displayCharacterstics.appBarHeight,
        elevation: 4,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(Icons.arrow_back),
          color: colorScheme.secondary,
          iconSize: displayCharacterstics.iconSize * 1.5,
          padding: displayCharacterstics.fullPadding / 2.5,
        ),
        leadingWidth: displayCharacterstics.paddingRaw * 3,
        actions: [
          // Add/Remove Teams
          IconButton.filledTonal(
            onPressed: scoreboard.teamCount < MAX_TEAMS
                ? () => _addTeam(context)
                : null,
            icon: Icon(Icons.add),
            tooltip: "Add Team",
          ),
          displayCharacterstics.halfSpacer,
          IconButton.filledTonal(
            onPressed: scoreboard.teamCount > 1
                ? () => _removeTeam(context)
                : null,
            icon: Icon(Icons.remove),
            tooltip: "Remove Team",
          ),
          displayCharacterstics.fullSpacer,
          ElevatedButton(
            onPressed: _saveAndExit,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: displayCharacterstics.fullPadding,
            ),
            child: const Text('Save & Exit'),
          ),
          displayCharacterstics.fullSpacer,
        ],
      ),
      body: Column(children: [Expanded(child: _buildGrid())]),
    );
  }

  Widget _buildGrid() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  for (int i = 0; i < _tempTeams.length; i++)
                    _buildCardWrapper(i),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardWrapper(int index) {
    if (index >= _tempTeams.length) return const SizedBox();
    return _TeamCard(
      index: index,
      data: _tempTeams[index],
      isEditingName: _editingNameId == index,
      onNameTap: () {
        setState(() {
          _editingNameId = index;
        });
      },
      onColorButtonTap: () => _showColorPicker(index),
      onNameChanged: (newName) {
        // Update local state only
        _tempTeams[index].name = newName;
      },
      onNameSubmitted: (newName) {
        setState(() {
          _tempTeams[index].name = newName;
          _editingNameId = null;
        });
      },
      onBlur: () {
        setState(() {
          _editingNameId = null;
        });
      },
    );
  }

  void _saveCurrentState(GlobalScoreboard scoreboard) {
    for (int i = 0; i < scoreboard.teamCount; i++) {
      // Ensure we don't go out of bounds if local state is out of sync (shouldn't happen)
      if (i < _tempTeams.length) {
        scoreboard.updateName(_tempTeams[i].name, i);
        scoreboard.updateColor(_tempTeams[i].seedColor, i);
      }
    }
  }

  void _addTeam(BuildContext context) {
    final scoreboard = context.read<GlobalScoreboard>();
    _saveCurrentState(scoreboard);
    scoreboard.addTeam();
  }

  void _removeTeam(BuildContext context) {
    final scoreboard = context.read<GlobalScoreboard>();
    _saveCurrentState(scoreboard);
    scoreboard.removeTeam();
  }

  void _saveAndExit() {
    final scoreboard = context.read<GlobalScoreboard>();
    _saveCurrentState(scoreboard);
    Navigator.of(context).pop();
  }

  void _showColorPicker(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: _ColorPickerPopup(
            selectedColor: _tempTeams[index].seedColor,
            onColorSelected: (color) {
              setState(() {
                _tempTeams[index].setSeedColor(color);
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}

class _TeamCard extends StatelessWidget {
  final int index;
  final _TeamData data;
  final bool isEditingName;
  final VoidCallback onNameTap;
  final VoidCallback onColorButtonTap;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onNameSubmitted;
  final VoidCallback onBlur;

  const _TeamCard({
    required this.index,
    required this.data,
    required this.isEditingName,
    required this.onNameTap,
    required this.onColorButtonTap,
    required this.onNameChanged,
    required this.onNameSubmitted,
    required this.onBlur,
  });

  @override
  Widget build(BuildContext context) {
    // Dimensions: 300px width x 180px height
    return SizedBox(
      width: 300,
      height: 180,
      child: Container(
        decoration: BoxDecoration(
          color: data.colorScheme.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEditingName ? onBlur : null,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Team Name or Input
                  if (isEditingName)
                    _buildNameInput()
                  else
                    GestureDetector(
                      onTap: onNameTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          data.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Sans-serif',
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Change Colour Button
                  if (!isEditingName)
                    GestureDetector(
                      onTap: onColorButtonTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(51),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Change Colour',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return SizedBox(
      width: 260,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Enter new team name",
            style: TextStyle(fontSize: 10, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: data.name,
            autofocus: true,
            style: const TextStyle(fontSize: 28, color: Colors.white),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black.withAlpha(77),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
            ),
            onChanged: onNameChanged,
            onFieldSubmitted: onNameSubmitted,
          ),
        ],
      ),
    );
  }
}

class _ColorPickerPopup extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorPickerPopup({
    required this.selectedColor,
    required this.onColorSelected,
  });

  static const List<Color> _palette = [
    Colors.red,
    Colors.purple,
    Colors.indigo,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lime,
    Colors.orange,
    Colors.brown,
    Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350, // Slightly wider to feel roomy or "popup" like
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select a colour",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: _palette.map((color) {
                final derivedColorScheme = deriveColorScheme(color);
                color = derivedColorScheme.secondary;
                final isSelected = selectedColor.value == color.value;
                return GestureDetector(
                  onTap: () => onColorSelected(color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withAlpha(102),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
