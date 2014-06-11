public class Radio.Station {

	public int	  id {get;set;}
	public string name {get;set;}
	public string url {get;set;}
	public string genre {get;set;}

	public Station(int id,string name,string url,string genre) {
		this.id = id;
		this.name = name;
		this.url = url;
		this.genre = genre;
	}

	public string to_string(){

		return @"$id | $name | $genre | $url \n";
	}
}

