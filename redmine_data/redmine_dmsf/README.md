Redmine DMSF Plugin
===================

The current version of Redmine DMSF is **2.4.11** 

[![pipeline status](https://gitlab.kontron.com/redmine-plugins/redmine_dmsf/badges/master/pipeline.svg)](https://gitlab.kontron.com/redmine-plugins/redmine_dmsf/pipelines/master/latest)

Redmine DMSF is Document Management System Features plugin for Redmine issue tracking system; It is aimed to replace current Redmine's Documents module.

Redmine DMSF now comes bundled with Webdav functionality: if switched on within plugin settings this will be accessible from /dmsf/webdav.

Webdav functionality is provided through DAV4Rack library.

Initial development was for Kontron AG R&D department and it is released as open source thanks to their generosity.  
Project home: <https://code.google.com/p/redmine-dmsf/>

Redmine Document Management System "Features" plugin is distributed under GNU General Public License v2 (GPL).  
Redmine is a flexible project management web application, released under the terms of the GNU General Public License v2 (GPL) at <https://www.redmine.org/>

Further information about the GPL license can be found at
<https://www.gnu.org/licenses/old-licenses/gpl-2.0.html#SEC1>

Features
--------

  * Directory structure
  * Document versioning / revision history
  * Email notifications for directories and/or documents
  * Document locking
  * Multi (drag/drop depending on browser) upload/download  
  * Direct document or document link sending via email
  * Configurable document approval workflow
  * Document access auditing
  * Integration with Redmine's activity feed
  * Wiki macros for quick content linking
  * Full read/write webdav functionality
  * Optional document content full-text search
  * Documents and folders symbolic links  
  * Trash bin
  * Documents attachable to issues
  * Compatible with Redmine 4.2.x

Dependencies
------------
  
  * Redmine 4.2.0 or higher

### Full-text search (optional)

If you want to use fulltext search abilities, install xapian packages. In case of using of Bitnami 
stack or Ruby installed via RVM it might be necessary to install Xapian bindings from sources. See https://xapian.org
 for details. 

To index some files with omega you may have to install some other packages like
xpdf, antiword, ...

From Omega documentation:

   * HTML (.html, .htm, .shtml, .shtm, .xhtml, .xhtm)
   * PHP (.php) - our HTML parser knows to ignore PHP code
   * text files (.txt, .text)
   * SVG (.svg)
   * CSV (Comma-Separated Values) files (.csv)
   * PDF (.pdf) if pdftotext is available (comes with poppler or xpdf)
   * PostScript (.ps, .eps, .ai) if ps2pdf (from ghostscript) and pdftotext (comes with poppler or xpdf) are available
   * OpenOffice/StarOffice documents (.sxc, .stc, .sxd, .std, .sxi, .sti, .sxm, .sxw, .sxg, .stw) if unzip is available
   * OpenDocument format documents (.odt, .ods, .odp, .odg, .odc, .odf, .odb, .odi, .odm, .ott, .ots, .otp, .otg, .otc, .otf, .oti, .oth) if unzip is available
   * MS Word documents (.dot) if antiword is available (.doc files are left to libmagic, as they may actually be RTF (AbiWord saves RTF when asked to save as .doc, and Microsoft Word quietly loads RTF files with a .doc extension), or plain-text).
   * MS Excel documents (.xls, .xlb, .xlt, .xlr, .xla) if xls2csv is available (comes with catdoc)
   * MS Powerpoint documents (.ppt, .pps) if catppt is available (comes with catdoc)
   * MS Office 2007 documents (.docx, .docm, .dotx, .dotm, .xlsx, .xlsm, .xltx, .xltm, .pptx, .pptm, .potx, .potm, .ppsx, .ppsm) if unzip is available
   * Wordperfect documents (.wpd) if wpd2text is available (comes with libwpd)
   * MS Works documents (.wps, .wpt) if wps2text is available (comes with libwps)
   * MS Outlook message (.msg) if perl with Email::Outlook::Message and HTML::Parser modules is available
   * MS Publisher documents (.pub) if pub2xhtml is available (comes with libmspub)
   * AbiWord documents (.abw)
   * Compressed AbiWord documents (.zabw)
   * Rich Text Format documents (.rtf) if unrtf is available
   * Perl POD documentation (.pl, .pm, .pod) if pod2text is available
   * reStructured text (.rst, .rest) if rst2html is available (comes with docutils)
   * Markdown (.md, .markdown) if markdown is available
   * TeX DVI files (.dvi) if catdvi is available
   * DjVu files (.djv, .djvu) if djvutxt is available
   * XPS files (.xps) if unzip is available
   * Debian packages (.deb, .udeb) if dpkg-deb is available
   * RPM packages (.rpm) if rpm is available
   * Atom feeds (.atom)
   * MAFF (.maff) if unzip is available
   * MHTML (.mhtml, .mht) if perl with MIME::Tools is available
   * MIME email messages (.eml) and USENET articles if perl with MIME::Tools and HTML::Parser is available
   * vCard files (.vcf, .vcard) if perl with Text::vCard is available
    
You can use following commands to install some of the required indexing tools:    

On Debian use:

```
sudo apt-get install xapian-omega ruby-xapian libxapian-dev poppler-utils antiword unzip catdoc libwpd-tools \
libwps-tools gzip unrtf catdvi djview djview3 uuid uuid-dev xz-utils libemail-outlook-message-perl
```

On Ubuntu use:

```
sudo apt-get install xapian-omega ruby-xapian libxapian-dev poppler-utils antiword  unzip catdoc libwpd-tools \
libwps-tools gzip unrtf catdvi djview djview3 uuid uuid-dev xz-utils libemail-outlook-message-perl
```

On CentOS use:
```
sudo yum install xapian-core xapian-bindings-ruby libxapian-dev poppler-utils antiword unzip catdoc libwpd-tools \
libwps-tools gzip unrtf catdvi djview djview3 uuid uuid-dev xz libemail-outlook-message-perl
```

Usage
-----

DMSF is designed to act as project module, so it must be checked as an enabled module within the project settings.

Search will now automatically search DMSF content when a Redmine search is performed, additionally a "Documents" and "Folders" check box will be visible, allowing you to search DMSF content exclusively.

Linking DMSF files from Wiki entries
------------------------------------

Link to a document with id 17: `{{dmsf(17)}}`

Link to a document with id 17 with link text "File": `{{dmsf(17, File)}}`

Link to the details of a document with id 17: `{{dmsfd(17)}}`

Link to the details of a document with id 17 with link text "Details": `{{dmsfd(17, Details)}}`

Text of the description of a document with id 17: `{{dmsfdesc(17)}}`

Text referring to the version of a document with id 17: `{{dmsfversion(17)}}`

Text referring to the last update date of a document with id 17: `{{dmsflastupdate(17)}}`

Link to the preview of 5 lines from a document with id 17: `{{dmsft(17, 5)}}`

Inline picture of the file with id 8; it must be an image file such as JPEG, PNG,...: `{{dmsf_image(8)}}`

Inline picture with custom size: `{{dmsf_image(8, size=300)}}`

Inline picture with custom size: `{{dmsf_image(8, size=50%)}}`

Inline picture with custom height: `{{dmsf_image(8, height=300)}}`

Inline picture with custom width: `{{dmsf_image(8, width=300)}}`

Inline picture with custom size: `{{dmsf_image(8, size=640x480)}}`

Thumbnail with height of 200px: `{{dmsftn(8)}}`

Thumbnail with custom size: `{{dmsftn(8, size=300)}}`

Inline video of the file with id 8; it must be a video file such as MP4: `{{dmsf_video(9)}}`

Inline video with custom size: `{{dmsf_video(9, size=300)}}`

Inline video with custom size: `{{dmsf_video(9, size=50%)}}`

Inline video with custom height: `{{dmsf_video(9, height=300)}}`

Inline video with custom width: `{{dmsf_video(9, width=300)}}`

Inline video with custom size: `{{dmsf_video(9, size=640x480)}}`

Approval workflow status of a document with id 8: `{{dmsfw(8)}}`

The DMSF document/revision id can be found in document details.

Linking DMSF folders from Wiki entries
--------------------------------------

Link to a folder with id 5: `{{dmsff(5)}}`

Link to a folder with id 5 with link text "Folder": `{{dmsff(5, Folder)}}`

The DMSF folder id can be found in the link when opening folders within Redmine.

You can also publish Wiki help description: 

In the file <redmine_root>/public/help/<language>/wiki_syntax_detailed.html, after the document link description/definition:

    <ul>
      <li>
        DMSF:
        <ul>
          <li><strong>{{dmsf(17)}}</strong> (a link to the file with id 17)</li>
          <li><strong>{{dmsf(17, File)}}</strong> (a link to the file with id 17 with the link text "File")</li>
          <li><strong>{{dmsf(17, File, 10)}}</strong> (a link to the file with id 17 with the link text "File" and the link pointing to the revision 10)</li>
          <li><strong>{{dmsfd(17)}}</strong> (a link to the details of the file with id 17)</li>
          <li><strong>{{dmsfdesc(17)}}</strong> (a link to the description of the file with id 17)</li>
          <li><strong>{{dmsff(5)}}</strong> (a link to the folder with id 5)</li>
          <li><strong>{{dmsff(5, Folder)}}</strong> (a link to the folder with id 5 with the link text "Folder")</li>
          <li><strong>{{dmsf_image(8)}}</strong> (an inline picture of the file with id 8; it must be an image file such as JPEG, PNG,...)</li>
          <li><strong>{{dmsf_image(8, size=300)}}</strong> (an inline picture with custom size)</li>
          <li><strong>{{dmsf_image(8, size=640x480)}}</strong> (an inline picture with custom size)</li>                    
          <li><strong>{{dmsf_image(8, size=50%)}}</strong> (an inline picture with custom size)</li>          
          <li><strong>{{dmsf_image(8, height=300)}}</strong> (an inline picture with custom size)</li>
          <li><strong>{{dmsf_image(8, width=300)}}</strong> (an inline picture with custom size)</li>
          <li><strong>{{dmsftn(8)}}</strong> (a thumbnail with height of 200px)</li>
          <li><strong>{{dmsftn(8, size=300)}}</strong> (a thumbnail with custom size)</li>
          <li><strong>{{dmsfw(8)}}</strong> (approval workflow status of a document with id 8)</li>
        </ul>
        The DMSF file/revision id can be found in the link for file/revision download from within Redmine.<br />
        The DMSF folder id can be found in the link when opening folders within Redmine.
      </li>
    </ul>

In the file <redmine_root>/public/help/<language>/wiki_syntax.html, at the end of the Redmine links section:

    <tr><th></th><td>{{dmsf(83)}}</td><td>Document <a href="#">#83</a></td></tr>    

There's a patch (tested with Redmine 3.4.2) that helps you to modify all help files at once. In your Redmine folder:

`cd redmine`

`patch -p0 < plugins/redmine_dmsf/extra/help_files_dmsf.diff`


Setup / Upgrade
---------------

You can either clone the master branch or download the latest zipped version. Before installing ensure that the Redmine instance is stopped.

    git clone git@github.com:danmunn/redmine_dmsf.git
       
    wget https://github.com/danmunn/redmine_dmsf/archive/master.zip

1. In case of upgrade **BACKUP YOUR DATABASE, ORIGINAL PLUGIN AND THE FOLDER WITH DOCUMENTS** first!!!
2. Put redmine_dmsf plugin directory into plugins. The plugins sub-directory must be named just **redmine_dmsf**. In case
   of need rename _redmine_dmsf-x.y.z_ to *redmine_dmsf*.
3. **Go to the redmine directory** `cd redmine`   
3. Install dependencies: `bundle install`.
4. Initialize/Update database:
    
    `RAILS_ENV=production bundle exec rake db:migrate`
    
    `RAILS_ENV=production bundle exec rake redmine:plugins:migrate NAME=redmine_dmsf`
5. The access rights must be set for web server, example: `chown -R www-data:www-data plugins/redmine_dmsf`.
6. Restart the web server, e.g. `systemctl restart apache2`
7. You should configure the plugin via Redmine interface: Administration -> Plugins -> DMSF -> Configure.
8. Don't forget to grant permissions for DMSF in Administration -> Roles and permissions
9. Assign DMSF permissions to appropriate roles.
10. There are a few rake tasks:

    I) To convert documents from the standard Redmine document module

        Available options:

            * project  => id or identifier of project (defaults to all projects)
            * dry  => true or false (default false) to perform just check without any conversion
            * invalid=replace  => to perform document title invalid characters replacement for '-'

        Example:
            
            rake redmine:dmsf_convert_documents project=test RAILS_ENV="production"

            (If you don't run the rake task as the web server user, don't forget to change the ownership of the imported files, e.g.
              chown -R www-data:www-data /redmine/files/dmsf
            afterwards)

    II) To alert all users who are expected to do an approval in the current approval steps

        Example:
            
            rake redmine:dmsf_alert_approvals RAILS_ENV="production"   
                        
    III) To create missing checksums for all document revisions
            
        Available options:
        
          *dry_run - test, no changes to the database          
          *forceSHA256 - replace old MD5 with SHA256
        
        Example:
        
          bundle exec rake redmine:dmsf_create_digests RAILS_ENV="production"
          bundle exec rake redmine:dmsf_create_digests forceSHA256=1 RAILS_ENV="production"
          bundle exec rake redmine:dmsf_create_digests dry_run=1 RAILS_ENV="production"
          
    IV) To maintain DMSF
        
        * Remove all files with no database record from the document directory
        * Remove all links project_id = -1 (added links to an issue which hasn't been created)
        
        Available options:
        
          *dry_run - No physical deletion but to list of all unused files only
        
        Example:
        
          rake redmine:dmsf_maintenance RAILS_ENV="production"
          rake redmine:dmsf_maintenance dry_run=1 RAILS_ENV="production"

### Installation in a sub-uri

In order to documents and folders are available via WebDAV in case that the Redmine is configured to be run in a sub-uri 
it's necessary to add the following configuration option into your `config/additional_environment.rb`:

```ruby
config.relative_url_root = '/redmine'
```

### Full-text search
If you want to use full-text search features, you must setup file content indexing.

It is necessary to index DMSF files with omindex before searching attempts to receive some output:

  1. Change the configuration part of redmine_dmsf/extra/xapian_indexer.rb file according to your environment.
     (The path to the index database set in xapian_indexer.rb must corresponds to the path set in the plugin's settings.)   
  2. Run `ruby redmine_dmsf/extra/xapian_indexer.rb -v`

This command should be run on regular basis (e.g. from cron)

Example of cron job (once per hour at 8th minute):
    
    8 * * * * root /usr/bin/ruby redmine_dmsf/extra/xapian_indexer.rb

See redmine_dmsf/extra/xapian_indexer.rb for help.

Uninstalling DMSF
-----------------
Before uninstalling the DMSF plugin, please ensure that the Redmine instance is stopped.

1. `cd [redmine-install-dir]`
2. `rake redmine:plugins:migrate NAME=redmine_dmsf VERSION=0 RAILS_ENV=production`
3. `rm plugins/redmine_dmsf -Rf`

After these steps re-start your instance of Redmine.

Contributing
------------

If you've added something, why not share it. Fork the repository (github.com/danmunn/redmine_dmsf), 
make the changes and send a pull request to the maintainers.

Changes with tests, and full documentation are preferred.

Additional Documentation
------------------------

[CHANGELOG.md](CHANGELOG.md) - Project changelog
[dmsf_user_guide.odt](dmsf_user_guide.odt) - User's guide

---

Special thanks to <a href="https://jetbrains.com"><img src="jetbrains-variant-3.svg" alt="JetBrains logo" width="59"  height="68"/></a> for providing an excelent IDE.
