import 'package:flutter/material.dart';

import 'package:drift/drift.dart';
import 'package:smooth_highlight/smooth_highlight.dart';

import 'package:anyportal/extensions/localization.dart';
import 'package:anyportal/screens/home/dashboard/direct_speed.dart';
import 'package:anyportal/screens/home/dashboard/proxy_speed.dart';
import 'package:anyportal/screens/home/dashboard/speed_chart.dart';
import '../../utils/db.dart';
import '../../utils/prefs.dart';
import '../../widgets/ray_toggle.dart';
import 'dashboard/perf_stats.dart';
import 'dashboard/traffic_stats.dart';

// ignore: must_be_immutable
class Dashboard extends StatefulWidget {
  Function setSelectedIndex;
  Dashboard({
    super.key,
    required this.setSelectedIndex,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<ProfileData> _profiles = [];
  ProfileData? _selectedProfile;

  bool _highlightSelectProfile = false;

  void setHighlightSelectProfile() async {
    for (var i = 0; i < 2; ++i) {
      if (mounted) {
        setState(() {
          _highlightSelectProfile = true;
        });
        await Future.delayed(const Duration(milliseconds: 1500));
      }
    }
  }

  Future<void> _loadSettings() async {
    final selectedProfileId = prefs.getInt('app.selectedProfileId');
    if (selectedProfileId != null) {
      final selectedProfile = await (db.select(db.profile)
            ..where((p) => p.id.equals(selectedProfileId)))
          .getSingleOrNull();
      if (mounted) {
        setState(() {
          _selectedProfile = selectedProfile;
        });
      }
    }
  }

  Future<void> _loadProfiles() async {
    final profiles = await (db.select(db.profile)
          ..orderBy([
            (u) => OrderingTerm(
                  expression: u.name,
                )
          ]))
        .get();
    if (mounted) {
      setState(() {
        _profiles = profiles;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.loc.dashboard),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(8.0),
          child: Wrap(children: [
            Card(
                margin: const EdgeInsets.all(8.0),
                child: SmoothHighlight(
                    enabled: _highlightSelectProfile,
                    color: Colors.grey,
                    child: ListTile(
                      title: Text(
                        context.loc.selected_profile,
                      ),
                      subtitle: Text(_selectedProfile == null
                          ? ""
                          : _selectedProfile!.name),
                      trailing: const Icon(Icons.more_vert),
                      onTap: () {
                        _profiles.isNotEmpty
                            ? widget.setSelectedIndex(2)
                            : () {
                                final snackBar = SnackBar(
                                  content: Text(context
                                      .loc.no_profile_yet_create_one_first),
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                                widget.setSelectedIndex(2);
                              }();
                      },
                    ))),
            Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    context.loc.speed_graph,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: const SpeedChart(),
                )),
            Row(children: [
              Expanded(
                  child: Card(
                margin: const EdgeInsets.all(8.0),
                child: Stack(children: [
                  Align(
                      alignment: Directionality.of(context) == TextDirection.ltr
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      child: Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.fromLTRB(0, 16, 24, 0),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      )),
                  ListTile(
                    title: Row(children: [
                      Text(
                        context.loc.direct_speed,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ]),
                    subtitle: const DirectSpeeds(),
                  )
                ]),
              )),
              Expanded(
                  child: Card(
                margin: const EdgeInsets.all(8.0),
                child: Stack(children: [
                  Align(
                      alignment: Directionality.of(context) == TextDirection.ltr
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      child: Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.fromLTRB(0, 16, 24, 0),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      )),
                  ListTile(
                    title: Text(
                      context.loc.proxy_speed,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: const ProxySpeeds(),
                  )
                ]),
              )),
            ]),
            Row(children: <Widget>[
              Expanded(
                child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        context.loc.performance,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: const PerfStats(),
                    )),
              ),
              Expanded(
                child: Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(context.loc.traffic),
                      subtitle: TrafficStats(),
                    )),
              ),
            ]),
            Container(
              constraints: const BoxConstraints(
                minHeight: 72,
              ),
            )
          ]),
        ),
        floatingActionButton: RayToggle(
          setHighlightSelectProfile: setHighlightSelectProfile,
        ));
  }
}
