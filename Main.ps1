$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
 
[xml]$config = Get-Content $directorypath"\libraries.xml"

 
foreach($library in $config.libraries.library){
    $web = Get-SPWeb $library.web
    $template = [Microsoft.SharePoint.SPListTemplateType]::($library.template)
    $web.Lists.Add($library.url,$library.description, $template);
    $web.Update();
    ForEach($culture in $web.SupportedUICultures){
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = $culture
        $list = $web.Lists[$library.url]
        $list.Title = $library.title
        $list.Update();
    }
    Write-Host $list.Title successfully created
    try{
        foreach($folder in $library.folders.folder){
            $list.RootFolder.SubFolders.add($folder);
        }
    }catch{
        # if it crashed here, the configuration did not include folders
        Write-Host Configuration did not include folders
    }
}
