/*
 * Copyright 2024 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Application : Gtk.Application {
    private const int ARGS_MAX = 2;

    public Application () {
        Object (
            application_id: "io.elementary.print",
            flags: ApplicationFlags.HANDLES_OPEN
        );
    }

    protected override void open (File[] files, string hint) {
        /*
         * We don't present the window because it's just for passing to run().
         * Although it's possible to pass null to run() but we don't do that
         * to avoid the following message:
         * "GtkDialog mapped without a transient parent. This is discouraged."
         */
        var main_window = new Gtk.Window ();

        var operation = new CustomOperation (files, main_window);
        try {
            operation.run (Gtk.PrintOperationAction.PRINT_DIALOG, main_window);
        } catch (Error err) {
            warning ("Failed to run print operation: %s", err.message);
        }
    }

    public static int main (string[] args) {
        if (args.length != ARGS_MAX) {
            stderr.printf ("Usage: %s <FILE>\n", args[0]);
            return 1;
        }

        return new Application ().run (args);
    }
}
