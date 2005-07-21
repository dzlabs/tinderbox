<?php

$rootdir = $_SERVER['DOCUMENT_ROOT'];

$wwwrooturi  = '/tinderbox';
$wwwrootdir  = $rootdir.$wwwrooturi;
$pkguri      = '/tb/packages';
$pkgdir      = $rootdir.$pkguri;
$loguri      = '/tb/logs';
$logdir      = $rootdir.$loguri;
$errorloguri = '/tb/errors';
$errorlogdir = $rootdir.$errorloguri;

$templatesdir = $wwwrootdir.'/templates/default';
$templatesuri = $wwwrooturi.'/templates/default';

$tinderbox_name  = 'Olivers Tinderbox';
$tinderbox_title = 'FooBar Packagebuild';

#$with_timer = 1;
?>
